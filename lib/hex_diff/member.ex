defmodule HexDiff.Member do
  defstruct name: nil, type: nil, arity: nil, meta: nil

  def from_code_docs({{type, name, arity}, _meta, _signature, _doc, _anno}) do
    %__MODULE__{name: name, type: type, arity: arity}
  end
end
