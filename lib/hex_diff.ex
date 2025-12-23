defmodule HexDiff do
  alias HexDiff.Resolvers
  alias HexDiff.Differ
  alias HexDiff.Outputs

  @moduledoc """
  Documentation for `HexDiff`.
  """

  # HexDiff.run("jason", "1.4.4", "1.2.2")
  #
  # DIFF: httpoison v1.0.0 - v2.2.1
  #
  # MAJOR
  #   - HTTPoison.request/3
  # MINOR
  #   + HTTPoison.request/4
  #
  def run(package_name, newer_version, older_version) do
    IO.puts("DIFF: #{package_name} #{older_version} - #{newer_version}")

    new_modules = Resolvers.Compiler.resolve(package_name, newer_version)
    old_modules = Resolvers.Compiler.resolve(package_name, older_version)

    diff = Differ.compare(new_modules, old_modules)

    IO.inspect(diff)

    IO.puts(Outputs.Text.encode(diff))
  end
end
