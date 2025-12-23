defmodule HexDiff.AST.Module do
  alias HexDiff.AST.Member

  @type t() :: %__MODULE__{
          name: String.t(),
          members: [Member.t()]
        }

  defstruct name: nil, members: []
end
