defmodule HexDiff.Outputs.Text do
  alias HexDiff.Diff

  @spec encode(Diff.t()) :: String.t()
  def encode(diff) do
    """

    ADDED
    #{Enum.map(diff.added, &"+ #{&1.name}\n")}
    #{top_level_changes(diff.changed, & &1.added, "+")}

    REMOVED
    #{Enum.map(diff.removed, &"- #{&1.name}\n")}
    #{top_level_changes(diff.changed, & &1.removed, "-")}

    CHANGED
    #{changes(diff.changed)}
    """
  end

  defp top_level_changes(diff, get_changes, prefix) do
    diff
    |> Enum.filter(fn {_module, diff} -> get_changes.(diff) != [] end)
    |> Enum.map(fn {module, diff} ->
      "= #{module.name}\n#{Enum.map(get_changes.(diff), &"  #{prefix} #{format(&1)}\n")}"
    end)
  end

  defp changes(changed) do
    changed
    |> Enum.map(fn {module, module_diff} ->
      "= #{module.name}" <>
        (module_diff.changed
         |> Enum.map(fn {member, changes} ->
           "\n  = #{format(member)}\n" <>
             (changes
              |> Enum.reject(&(&1 == :unchanged))
              |> Enum.map(fn change ->
                """
                    + #{Macro.to_string(change.new_spec)}
                    - #{Macro.to_string(change.old_spec)}

                    #{Macro.to_string(elem(change.change, 0))} -> #{Macro.to_string(elem(change.change, 1))}
                """
              end)
              |> Enum.join("\n"))
         end)
         |> Enum.join("\n"))
    end)
    |> Enum.join("\n")
  end

  defp format(member) do
    case member.type do
      type when type in [:function, :macro] -> "#{member.name}/#{member.arity}"
      :type -> "@type #{member.name}()"
      _ -> "#{member.type} #{member.name}"
    end
  end
end
