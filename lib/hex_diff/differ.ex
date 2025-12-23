defmodule HexDiff.Differ do
  alias HexDiff.Diff

  @spec compare([Module.t()], [Module.t()]) :: Diff.t()
  def compare(new_modules, old_modules) do
    module_diff = diff_with(new_modules, old_modules, & &1.name, fn new, old -> {new, old} end)

    %Diff{
      added: module_diff.added,
      removed: module_diff.removed,
      kept: Enum.map(module_diff.kept, fn {new, old} -> {new, diff_module(new, old)} end)
    }
  end

  def diff_with(new_items, old_items, key_fun, on_conflict) do
    old_map = Enum.into(old_items, %{}, fn item -> {key_fun.(item), item} end)
    new_map = Enum.into(new_items, %{}, fn item -> {key_fun.(item), item} end)

    all_keys = MapSet.union(MapSet.new(Map.keys(old_map)), MapSet.new(Map.keys(new_map)))

    Enum.reduce(all_keys, %Diff{}, fn key, acc ->
      case {new_map[key], old_map[key]} do
        {new_item, nil} ->
          %{acc | added: [new_item | acc.added]}

        {nil, old_item} ->
          %{acc | removed: [old_item | acc.removed]}

        {same, same} ->
          %{acc | kept: [on_conflict.(same, same) | acc.kept]}

        {new_item, old_item} ->
          # TODO: changed
          %{acc | kept: [{new_item, old_item} | acc.kept]}
      end
    end)
  end

  defp diff_module(new, old) do
    diff_with(
      new.members,
      old.members,
      fn member ->
        if member.type in [:function, :macro] do
          {:function_or_macro, member.name, member.arity}
        else
          {member.type, member.name, member.arity}
        end
      end,
      fn new, _old -> new end
    )
  end
end
