defmodule HexDiff.Resolvers.Compiler do
  @type module_map() :: map()

  @spec resolve(String.t(), String.t()) :: module_map()
  def resolve(package, version) do
    File.mkdir_p!(".hex_diff")

    File.cd!(".hex_diff", fn ->
      IO.puts("fetching #{package} v#{version}")
      fetch_package!(package, version)
    end)

    package
    |> load_source(version)
    |> beam_to_modulemap()
  end

  defp beam_to_modulemap(files) do
    files
    |> Enum.map(fn file ->
      {Path.basename(file) |> String.replace_trailing(".beam", ""), Code.fetch_docs(file)}
    end)
    |> Enum.reject(fn
      {_, {:docs_v1, _, _language, _format, :hidden, _, _}} -> true
      _ -> false
    end)
    |> Enum.map(fn
      {module, {:docs_v1, _, _language, _format, _moduledoc, _meta, docs_list}} ->
        {module, find_public_members(docs_list)}
    end)
    |> Map.new()
  end

  defp find_public_members(docs_list) do
    docs_list
    |> Enum.reject(fn
      {_def, _, _, :hidden, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {member, _, _, _, _} -> member end)
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
