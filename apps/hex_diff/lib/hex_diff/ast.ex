defmodule HexDiff.AST do
  alias HexDiff.AST.Module
  alias HexDiff.AST.Member

  def from_beam(file) do
    name = Path.basename(file) |> String.replace_trailing(".beam", "")

    case Code.fetch_docs(file) do
      {:docs_v1, _anno, _language, _format, :hidden, _meta, _doc_content} ->
        {:error, :hidden}

      {:docs_v1, _anno, _language, _format, _moduledoc, _meta, doc_content} ->
        {:ok,
         %Module{
           name: name,
           members:
             Enum.map(doc_content, fn {{type, name, arity}, _meta, _signature, _doc, _anno} ->
               %Member{name: name, type: type, arity: arity}
             end)
         }}

      _ ->
        {:error, :unexpected_docs}
    end
  end

  @spec from_signatures(String.t(), [{type :: String.t(), content :: String.t()}]) :: Module.t()
  def from_signatures(name, signatures) do
    %Module{
      name: name,
      members:
        Enum.reduce(signatures, [], fn signature, acc ->
          case parse_signature(signature) do
            {:ok, member} -> [member | acc]
            {:error, _} -> acc
          end
        end)
    }
  end

  defp parse_signature({type, content, typespec}) do
    with true <- type in ["macro", "function", "callback", "type"],
         # TODO: sanitize content
         {:ok, {name, _meta, args}} <- Code.string_to_quoted(content),
         {:ok, typespec} <- parse_typespec(typespec) do
      {:ok,
       %Member{
         name: name,
         type: String.to_existing_atom(type),
         arity: length(args),
         typespec: typespec
       }}
    else
      _ -> {:error, :invalid_signature}
    end
  end

  defp parse_typespec(spec) do
    case Code.string_to_quoted(spec) do
      {:ok, spec} -> {:ok, spec}
      _error -> {:ok, nil}
    end
  end
end
