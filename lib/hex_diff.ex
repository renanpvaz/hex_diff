defmodule HexDiff do
  alias HexDiff.AST
  alias HexDiff.SemVer

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
  def run_2(package_name, version_a, version_b) do
    File.mkdir_p!(".hex_diff")

    File.cd!(".hex_diff", fn ->
      IO.puts("fetching #{package_name} v#{version_a}")
      fetch_package!(package_name, version_a)

      IO.puts("fetching #{package_name} v#{version_b}")
      fetch_package!(package_name, version_b)
    end)

    (load_source(package_name, version_a) ++ load_source(package_name, version_b))
    |> tap(fn source -> IO.inspect(length(source), label: "loaded") end)
    |> Enum.flat_map(&AST.parse/1)
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn
      {name, [module_a, module_b]} -> {name, diff_module(module_a, module_b)}
      {name, [_module_a]} -> {name, %{removals: 0, additions: 0}}
    end)
    |> SemVer.classify()
  end

  defp load_source(package, version) do
    qualified_name = "#{package}-#{version}"

    File.cd!(".hex_diff", fn ->
      Path.join([qualified_name, "**/*.ex"])
      |> Path.wildcard()
      |> Enum.map(&File.read!/1)
    end)
  end

  defp fetch_package!(name, version) do
    qualified_name = "#{name}-#{version}"

    {:ok, {200, _, tarball}} =
      :hex_repo.get_tarball(:hex_core.default_config(), name, version)

    {:ok, %{outer_checksum: _checksum, metadata: _metadata}} =
      :hex_tarball.unpack(tarball, String.to_charlist(qualified_name))
  end

  def diff_module(a, b) do
    functions_a = a.public
    functions_b = b.public

    # TODO optimize
    removals = functions_a -- functions_b
    additions = functions_b -- functions_a

    %{removals: removals, additions: additions}
  end
end
