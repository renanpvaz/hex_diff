defmodule HexDiff.Outputs.Text do
  alias HexDiff.Diff

  @spec encode(Diff.t()) :: String.t()
  def encode(diff) do
    """

    ADDED
    #{Enum.map(diff.added, &"+ #{&1.name}\n")}
    #{changes(diff.kept, & &1.added, "+")}

    REMOVED
    #{Enum.map(diff.removed, &"- #{&1.name}\n")}
    #{changes(diff.kept, & &1.removed, "-")}
    """
  end

  defp changes(diff, get_changes, prefix) do
    diff
    |> Enum.filter(fn {_module, diff} -> get_changes.(diff) != [] end)
    |> Enum.map(fn {module, diff} ->
      "= #{module.name}\n#{Enum.map(get_changes.(diff), &"  #{prefix} #{format(&1)}\n")}"
    end)
  end

  defp format(member) do
    case member.type do
      type when type in [:function, :macro] -> "#{member.name}/#{member.arity}"
      :type -> "@type #{member.name}()"
      _ -> "#{member.type} #{member.name}"
    end
  end
end
