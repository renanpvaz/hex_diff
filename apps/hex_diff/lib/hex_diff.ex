defmodule HexDiff do

  require Logger

  alias HexDiff.Resolvers
  alias HexDiff.AST
  alias HexDiff.Differ
  alias HexDiff.Outputs

  @moduledoc """
  Documentation for `HexDiff`.
  """

  # HexDiff.run("jason", "1.4.4", "1.2.2")
  # HexDiff.run("req", "0.5.5", "0.4.14")
  #
  def run(package_name, newer_version, older_version) do
    IO.puts("DIFF: #{package_name} #{older_version} - #{newer_version}")
    Logger.info("hexdiff.run", package: package_name, versions: [newer_version, older_version])

    {:ok, new_scraped_data} = Resolvers.Scraper.resolve(package_name, newer_version)
    {:ok, old_scraped_data} = Resolvers.Scraper.resolve(package_name, older_version)

    new_modules =
      Enum.map(new_scraped_data, fn {name, signatures} ->
        AST.from_signatures(name, signatures)
      end)


    old_modules =
      Enum.map(old_scraped_data, fn {name, signatures} ->
        AST.from_signatures(name, signatures)
      end)

    diff = Differ.compare(new_modules, old_modules)

    IO.inspect(diff.changed)

    result = Outputs.Text.encode(diff)
    IO.puts(result)
    result
  end
end
