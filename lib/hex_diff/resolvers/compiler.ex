defmodule HexDiff.Resolvers.Compiler do
  alias HexDiff.AST

  @spec resolve(package :: String.t(), version :: String.t()) :: [Module.t()]
  def resolve(package, version) do
    File.mkdir_p!(".hex_diff")

    File.cd!(".hex_diff", fn ->
      IO.puts("fetching #{package} v#{version}")
      fetch_package!(package, version)
    end)

    package
    |> load_source(version)
    |> beam_to_module()
  end

  defp beam_to_module(files) do
    Enum.reduce(files, [], fn file, acc ->
      case AST.from_beam(file) do
        {:ok, module} -> [module | acc]
        {:error, _} -> acc
      end
    end)
  end

  defp load_source(package, version) do
    qualified_name = "#{package}-#{version}"

    ".hex_diff"
    |> Path.join(qualified_name)
    |> File.cd!(fn ->
      File.mkdir_p!("ebin")

      IO.puts("compiling #{package} #{version}")

      result =
        "**/*.ex"
        |> Path.wildcard()
        |> Kernel.ParallelCompiler.compile_to_path("ebin", return_diagnostics: true)

      case result do
        {:ok, modules, _} ->
          IO.puts("loaded #{length(modules)} modules")

          "ebin/*.beam"
          |> Path.wildcard()
          |> Enum.map(&Path.expand/1)

        {:error, errors, _} ->
          Enum.each(errors, &IO.puts(&1.message))
          []
      end
    end)
  end

  defp fetch_package!(name, version) do
    qualified_name = "#{name}-#{version}"

    {:ok, {200, _, tarball}} =
      :hex_repo.get_tarball(:hex_core.default_config(), name, version)

    {:ok, %{outer_checksum: _checksum, metadata: _metadata}} =
      :hex_tarball.unpack(tarball, String.to_charlist(qualified_name))
  end
end
