defmodule HexDiff do
  alias HexDiff.Resolvers

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

    File.mkdir_p!(".hex_diff")

    new_modules = Resolvers.Compiler.resolve(package_name, newer_version)
    old_modules = Resolvers.Compiler.resolve(package_name, older_version)

    all_modules = Map.merge(new_modules, old_modules)

    IO.puts("diffing modules")

    modules_diff = diff(Map.keys(all_modules), Map.keys(new_modules), Map.keys(old_modules))

    members_diff =
      Enum.map(modules_diff.kept, fn module ->
        new_members = Map.get(new_modules, module)
        old_members = Map.get(old_modules, module)

        {module, diff(new_members ++ old_members, new_members, old_members)}
      end)

    result = %{modules_diff | kept: members_diff}
    IO.inspect(result)
    emit_result(result)
  end

  defp emit_result(diff) do
    IO.puts("\nADDED")

    diff.added
    |> Enum.map(&"+ #{&1}\n")
    |> IO.puts()

    diff.kept
    |> Enum.filter(fn {_module, diff} -> diff.added != [] end)
    |> Enum.map(fn {module, diff} ->
      "= #{module}\n#{Enum.map(diff.added, &"  + #{format(&1)}\n")}"
    end)
    |> IO.puts()

    IO.puts("\nREMOVED")

    diff.removed
    |> Enum.map(&"- #{&1}\n")
    |> IO.puts()

    diff.kept
    |> Enum.filter(fn {_module, diff} -> diff.removed != [] end)
    |> Enum.map(fn {module, diff} ->
      "= #{module}\n#{Enum.map(diff.removed, &"- #{format(&1)}\n")}"
    end)
    |> IO.puts()
  end

  defp format({:function, name, arity}) do
    "#{name}/#{arity}"
  end

  defp format({:type, name, _arity}) do
    "@type #{name}()"
  end

  defp format({type, name, _arity}) do
    "#{type} #{name}"
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
end
