defmodule HexDiff.AST do
  alias HexDiff.AST.Module

  # takes raw AST and returns
  # %HexDiff.AST.Module{name: [], public: [], private: [], types: []}
  def parse(raw_ast) do
    Enum.map(raw_ast, &Module.new/1)
  end
end
