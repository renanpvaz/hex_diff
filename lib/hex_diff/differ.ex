defmodule HexDiff.Differ do
  alias HexDiff.Diff
  alias HexDiff.Diff.Module
  alias HexDiff.Diff.Typespec

  @spec compare([Module.t()], [Module.t()]) :: Diff.t()
  def compare(new_modules, old_modules) do
    modules =
      [new_modules, old_modules] =
      Enum.map(
        [new_modules, old_modules],
        &Enum.into(&1, %{}, fn module -> {module.name, module} end)
      )

    keys = modules |> Enum.flat_map(&Map.keys/1) |> Enum.uniq()

    Enum.reduce(keys, %Diff{}, fn key, acc ->
      case {new_modules[key], old_modules[key]} do
        {new_item, nil} ->
          %{acc | added: [new_item | acc.added]}

        {nil, old_item} ->
          %{acc | removed: [old_item | acc.removed]}

        {same, same} ->
          %{acc | preserved: [same | acc.preserved]}

        {new_item, old_item} ->
          %{acc | changed: [{new_item, diff_module(new_item, old_item)} | acc.changed]}
      end
    end)
  end

  defp diff_module(new_module, old_module) do
    members =
      [new_members, old_members] =
      Enum.map(
        [new_module.members, old_module.members],
        &Enum.into(&1, %{}, fn member -> {member_to_key(member), member} end)
      )

    keys = members |> Enum.flat_map(&Map.keys/1) |> Enum.uniq()

    Enum.reduce(keys, %Diff{}, fn key, acc ->
      case {new_members[key], old_members[key]} do
        {new_item, nil} ->
          %{acc | added: [new_item | acc.added]}

        {nil, old_item} ->
          %{acc | removed: [old_item | acc.removed]}

        {new_item, old_item} ->
          cond do
            new_item == old_item ->
              %{acc | preserved: [new_item | acc.preserved]}

            new_item.typespec != old_item.typespec ->
              case compare_typespecs(new_item.typespec, old_item.typespec) do
                {:ok, changes} ->
                  %{acc | changed: [{new_item, changes} | acc.changed]}

                {:error, _} ->
                  %{acc | preserved: [new_item | acc.preserved]}
              end
          end
      end
    end)
  end

  defp member_to_key(member) do
    if member.type in [:function, :macro] do
      {:function_or_macro, member.name, member.arity}
    else
      {member.type, member.name, member.arity}
    end
  end

  # TODO: create typespec struct early, carry down values
  def compare_typespecs({:@, _, [{type, _, [new_content]}]}, {:@, _, [{type, _, [old_content]}]}) do
    compare_typespecs(new_content, old_content)
  end

  def compare_typespecs({:@, _, [{_type, _, _}]}, {:@, _, [{_, _, _}]}) do
    {:error, :type_mismatch}
  end

  # TODO: check return type
  def compare_typespecs(
        {:"::", _, [{name, _, new_args}, _return]},
        {:"::", _, [{name, _, old_args}, _]}
      ) do
    compare_typespecs(new_args, old_args)
  end

  def compare_typespecs(
        {:"::", _, _},
        {:"::", _, _}
      ) do
    {:error, :name_mismatch}
  end

  def compare_typespecs(new, old) when is_list(new) and is_list(old) do
    if length(new) != length(old) do
      {:error, :arity_mismatch}
    else
      {:ok,
       Enum.zip(new, old)
       |> Enum.reduce([], fn
         {new, old}, acc ->
           case compare_typespecs(new, old) do
             {:ok, diff} -> acc ++ List.wrap(diff)
             {:error, _} -> acc
           end
       end)}
    end
  end

  def compare_typespecs({new_type, _, new_value} = new, {old_type, _, old_value} = old) do
    cond do
      new_type == old_type and new_value == old_value ->
        {:ok, :unchanged}

      new_type == old_type ->
        {:ok, %Typespec{new_spec: new, old_spec: old, change: {new_value, old_value}}}

      new_value == old_value ->
        {:ok, %Typespec{new_spec: new, old_spec: old, change: {new_type, old_type}}}

      true ->
        {:error, {:unexpected_comparison, new, old}}
    end
  end

  def compare_typespecs(new, old) do
    cond do
      is_nil(new) and is_nil(old) -> {:ok, :unchanged}
      is_nil(new) -> {:ok, %Typespec{new_spec: nil, old_spec: old, change: {nil, nil}}}
      is_nil(old) -> {:ok, %Typespec{new_spec: new, old_spec: nil, change: {nil, nil}}}
      true -> {:error, :no_match}
    end
  end
end
