defmodule HexDiff.Resolvers.Scraper do
  alias HexDiff.AST
  alias HexDiff.Hex

  @spec resolve(package :: String.t(), version :: String.t()) ::
          {:ok, [Module.t()]} | {:error, any()}
  def resolve(package, version) do
    with :ok <- File.mkdir_p(".hex_diff"),
         {:ok, path} <- Hex.fetch_docs(package, version, ".hex_diff"),
         {:ok, module_paths} <- find_module_paths(path) do
      parse_documents(module_paths)
    end
  end

  defp find_module_paths(path) do
    with {:ok, parsed_document} <- Path.join(path, "api-reference.html") |> parse_html() do
      {:ok,
       Floki.find(parsed_document, ".summary-signature")
       |> Enum.map(&Floki.text/1)
       |> Enum.map(&Path.join(path, "#{&1}.html"))}
    end
  end

  defp parse_documents(paths) do
    paths
    |> Task.async_stream(fn path ->
      name = Path.basename(path) |> String.replace_trailing(".html", "")

      with {:ok, html_tree} <- parse_html(path),
           {:ok, module} <- parse_module_tree(name, html_tree) do
        {:ok, module}
      end
    end)
    |> Enum.reduce({:ok, []}, fn
      {:ok, parsed}, {:ok, modules} -> {:ok, [parsed | modules]}
      {:error, error}, _ -> {:error, error}
      _, error -> error
    end)
  end

  defp parse_module_tree(name, tree) do
    signatures =
      tree
      |> Floki.find(".detail-header")
      |> Enum.map(fn detail ->
        signature = Floki.find(detail, ".signature") |> Floki.text()
        macro? = Floki.find(detail, ".note") |> Floki.text() |> Kernel.=~("macro")
        # TODO: parse spec
        type = if macro?, do: "macro", else: "function"

        {type, signature}
      end)

    AST.from_signatures(name, signatures)
  end

  defp parse_html(path) do
    with {:ok, api_reference} <- File.read(path) do
      Floki.parse_document(api_reference)
    end
  end
end
