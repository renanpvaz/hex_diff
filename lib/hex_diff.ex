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

  def run(package_name, version_a, version_b) do
    {:ok, package} = resolve_package(package_name, version_a, version_b)

    IO.inspect(package)

    SCM.checkout(dest: "packages", origin: package.github)

    (SCM.read(package.name, version_a) ++
       SCM.read(package.name, version_b))
    |> Enum.flat_map(&AST.parse/1)
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {name, [module_a, module_b]} -> {name, diff_module(module_a, module_b)} end)
    |> SemVer.classify()
  end

  defp resolve_package(package, version_a, version_b) do
    with {:ok, {200, result, _}} <- Hex.API.Package.get(nil, package),
         {:ok, package} <- parse_package_response(result),
         {:ok, _} <- check_versions(package, [version_a, version_b]) do
      {:ok, package}
    else
      {:ok, {404, _}} -> {:error, :package_not_found}
      error -> IO.inspect(error)
    end
  end

  defp parse_package_response(result) do
    versions = Enum.map(result["releases"], & &1["version"])

    {:ok,
     %{
       name: result["name"],
       github: result["meta"]["links"]["GitHub"],
       versions: versions
     }}
  end

  defp check_versions(package, versions) do
    case Enum.find(versions, &(&1 not in package.versions)) do
      nil -> {:ok, versions}
      version -> {:error, {:invalid_version, version}}
    end
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
