defmodule HexDiff.Modules do
  def diff(a, b) do
    functions_a = functions(a)
    functions_b = functions(b)

    # TODO optimize
    removals = functions_a -- functions_b
    additions = functions_b -- functions_a

    %{removals: removals, additions: additions}
  end

  # TODO take AST instead of live module
  defp functions(module) do
    module.__info__(:functions)
    |> Enum.sort()
  end
end
