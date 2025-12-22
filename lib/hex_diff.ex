defmodule HexDiff do
  alias HexDiff.Module

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
    File.mkdir_p!(".hex_diff")

    File.cd!(".hex_diff", fn ->
      IO.puts("fetching #{package_name} v#{newer_version}")
      fetch_package!(package_name, newer_version)

      IO.puts("fetching #{package_name} v#{older_version}")
      fetch_package!(package_name, older_version)
    end)

    new_files = load_source(package_name, newer_version)
    old_files = load_source(package_name, older_version)

    new_modules = beam_to_modules(new_files)
    old_modules = beam_to_modules(old_files)

    all_modules = Map.merge(new_modules, old_modules)

    IO.puts("diffing modules")

    modules_diff = diff(Map.keys(all_modules), Map.keys(new_modules), Map.keys(old_modules))

    IO.inspect(modules_diff)

    members_diff =
      Enum.map(modules_diff.kept, fn module ->
        new_members = Map.get(new_modules, module)
        old_members = Map.get(old_modules, module)

        {module, diff(new_members ++ old_members, new_members, old_members)}
      end)

    %{modules_diff | kept: members_diff}
  end

  defp diff(all_values, new_values, old_values) do
    Enum.reduce(all_values, %{added: [], removed: [], kept: []}, fn
      element, acc ->
        new? = element in new_values
        old? = element in old_values

        key =
          cond do
            new? && old? -> :kept
            new? -> :added
            old? -> :removed
          end

        Map.update(acc, key, nil, &[element | &1])
    end)
  end

  defp beam_to_modules(files) do
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

      {:ok, modules, _} =
        "**/*.ex"
        |> Path.wildcard()
        |> Kernel.ParallelCompiler.compile_to_path("ebin", return_diagnostics: true)

      IO.puts("loaded #{length(modules)} modules")

      Path.wildcard("ebin/*.beam")
      |> Enum.map(&Path.expand/1)
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
