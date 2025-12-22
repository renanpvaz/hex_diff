defmodule HexDiff.Differ do
  alias HexDiff.Diff
  alias HexDiff.ModuleMap

  @spec compare(ModuleMap.t(), ModuleMap.t()) :: Diff.t()
  def compare(new, old) do
    modules_diff = diff(ModuleMap.names(new), ModuleMap.names(old))

    members_diff =
      Enum.map(modules_diff.kept, fn module ->
        new_members = ModuleMap.get(new, module)
        old_members = ModuleMap.get(old, module)

        {module, diff(new_members, old_members)}
      end)

    %{modules_diff | kept: members_diff}
  end

  defp diff(new_values, old_values) do
    all_values = Enum.uniq(new_values ++ old_values)

    Enum.reduce(all_values, %Diff{}, fn
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
