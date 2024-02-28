defmodule HexDiff.SemVer do
  # [
  # {[:HTTPoison, :Base],
  #  %{
  #    additions: [maybe_process_form: 1, maybe_process_form: 1, request!: 1],
  #    removals: []
  #  }},
  #  ]
  def classify(execution) do
    breaking = breaking_changes(execution)

    cond do
      not is_nil(breaking) -> {:major, execution}
      any_changes?(execution) -> {:minor, execution}
      true -> {:patch, execution}
    end
  end

  defp breaking_changes(execution) do
    Enum.find(execution, fn {module_name, changes} -> length(changes.removals) > 0 end)
  end

  defp any_changes?(execution) do
    Enum.any?(execution, fn {module_name, changes} -> length(changes.additions) > 0 end)
  end
end
