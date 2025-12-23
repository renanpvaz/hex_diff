defmodule HexDiff do
  alias HexDiff.Resolvers
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

    {:ok, new_modules} = Resolvers.Scraper.resolve(package_name, newer_version)
    {:ok, old_modules} = Resolvers.Scraper.resolve(package_name, older_version)

    diff = Differ.compare(new_modules, old_modules)

    IO.puts(Outputs.Text.encode(diff))
  end
end
