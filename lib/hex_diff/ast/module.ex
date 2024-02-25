defmodule HexDiff.AST.Module do
  alias Sourceror.Zipper, as: Z

  # %HexDiff.AST.Module{
  #  name: [:HTTPoison, :Request],
  #  public: [message: 1, message: 1, to_curl: 1]
  # }
  #
  # TODO: types
  # types: [message/1: {param1, param2, return}]
  defstruct name: nil, public: nil

  def new(raw_ast) do
    zipper = Z.zip(raw_ast)

    # TODO: traverse ast once
    {_, _, module_name} =
      zipper
      |> Z.find(fn
        {name, _, _} -> name == :__aliases__
        _ -> false
      end)
      |> Z.node()

    {_zipper, public_functions} =
      zipper
      |> Z.traverse([], fn zipper, acc ->
        case Z.node(zipper) do
          {:def, _, _} ->
            {zipper, [function(zipper) | acc]}

          _ ->
            {zipper, acc}
        end
      end)

    %__MODULE__{name: module_name, public: public_functions}
  end

  def function(zipper) do
    {name, _, arguments} = Z.down(zipper) |> Z.node()
    {name, length(arguments || [])}
  end
end
