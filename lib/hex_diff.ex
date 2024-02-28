defmodule HexDiff do
  alias HexDiff.SCM
  alias HexDiff.AST
  alias HexDiff.SemVer

  @moduledoc """
  Documentation for `HexDiff`.
  """

  # HexDiff.run(:httpoison, "v1.0.0", "v2.2.1")
  #
  # DIFF: httpoison v1.0.0 - v2.2.1
  #
  # MAJOR
  #   - HTTPoison.request/3
  # MINOR
  #   + HTTPoison.request/4

  def run(package, version_a, version_b) do
    SCM.checkout(dest: "packages", origin: package)

    (SCM.read("httpoison", version_a) ++
       SCM.read("httpoison", version_b))
    |> Enum.flat_map(&AST.parse/1)
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {name, [module_a, module_b]} -> {name, diff_module(module_a, module_b)} end)
    |> SemVer.classify()
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
