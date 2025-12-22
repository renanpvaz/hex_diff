defmodule HexDiff.Outputs.Text do
  alias HexDiff.Diff

  @spec encode(Diff.t()) :: String.t()
  def encode(diff) do
    """
    ADDED

    #{Enum.map(diff.added, &"+ #{&1}\n")}

    #{diff.kept |> Enum.filter(fn {_module, diff} -> diff.added != [] end) |> Enum.map(fn {module, diff} -> "= #{module}\n#{Enum.map(diff.added, &"  + #{format(&1)}\n")}" end)}

     REMOVED

    #{Enum.map(diff.removed, &"- #{&1}\n")}

    #{diff.kept |> Enum.filter(fn {_module, diff} -> diff.removed != [] end) |> Enum.map(fn {module, diff} -> "= #{module}\n#{Enum.map(diff.removed, &"- #{format(&1)}\n")}" end)}
    """
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
end
