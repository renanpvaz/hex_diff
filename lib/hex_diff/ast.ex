defmodule HexDiff.AST do
  alias HexDiff.AST.Module

  # takes raw file contents and returns
  # %HexDiff.AST.Module{name: [], public: [], private: [], types: []}
  @spec parse([String.t()]) :: [Module.t()]
  def parse(raw_strings) do
    raw_strings
    |> List.wrap()
    |> Enum.map(&Code.string_to_quoted!/1)
    |> Enum.map(&Module.new/1)
  end
end
