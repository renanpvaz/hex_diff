defmodule HexDiff.Resolvers.Scraper do
  alias HexDiff.Hex

  @type result :: {String.t(), [signature()]}

  @type signature :: {type :: String.t(), content :: String.t()}

  @spec resolve(package :: String.t(), version :: String.t()) ::
          {:ok, [result()]} | {:error, any()}
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
    function_signatures =
      Floki.find(tree, "#functions")
      |> parse_signatures()
      |> Enum.map(fn {sig, note} ->
        if note =~ "macro" do
          {"macro", sig}
        else
          {"function", sig}
        end
      end)

    type_signatures =
      Floki.find(tree, "#types")
      |> parse_signatures()
      |> Enum.map(fn {sig, _note} -> {"type", sig} end)

    {name, function_signatures ++ type_signatures}
  end

  defp parse_signatures(tree) do
    tree
    |> Floki.find(".detail-header")
    |> Enum.map(fn detail ->
      signature = Floki.find(detail, ".signature") |> Floki.text()
      note = Floki.find(detail, ".note") |> Floki.text()

      {signature, note}
    end)
  end

  defp parse_html(path) do
    with {:ok, api_reference} <- File.read(path) do
      Floki.parse_document(api_reference)
    end
  end
end
