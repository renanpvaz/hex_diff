defmodule HexDiff.AST.Member do
  @type t() :: %__MODULE__{
          name: String.t(),
          type: :function | :macro | :callback | :type,
          arity: non_neg_integer(),
          typespec: any(),
          meta: any()
        }

  defstruct name: nil, type: nil, arity: nil, typespec: nil, meta: nil
end
