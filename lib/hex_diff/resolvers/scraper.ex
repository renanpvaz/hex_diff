defmodule HexDiff.Resolvers.Scraper do
  alias HexDiff.AST

  @spec resolve(package :: String.t(), version :: String.t()) :: [Module.t()]
  def resolve(package, version) do
    File.mkdir_p!(".hex_diff")

    File.cd!(".hex_diff", fn ->
      IO.puts("fetching docs for #{package} v#{version}")
      path = fetch_docs!(package, version)

      File.cd!(path, &parse_api/0)
    end)
  end

  defp parse_api() do
    File.read!("api-reference.html")
    |> Floki.parse_document!()
    |> Floki.find(".summary-signature")
    |> Enum.map(&Floki.text/1)
    |> Enum.map(&parse_document/1)
  end

  defp parse_document(name) do
    signatures =
      File.read!("#{name}.html")
      |> Floki.parse_document!()
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

  defp fetch_docs!(name, version) do
    path = "#{name}-#{version}/docs"

    {:ok, {200, _, tarball}} =
      :hex_repo.get_docs(:hex_core.default_config(), name, version)

    :ok = :hex_tarball.unpack_docs(tarball, String.to_charlist(path))
    path
  end
end
