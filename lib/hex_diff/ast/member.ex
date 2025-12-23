defmodule HexDiff.AST.Member do
  @type t() :: %__MODULE__{
          name: String.t(),
          type: :function | :macro | :callback | :type,
          arity: non_neg_integer(),
          meta: any()
        }

  defstruct name: nil, type: nil, arity: nil, meta: nil
end
