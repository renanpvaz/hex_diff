defmodule HexDiff.Module do
  alias HexDiff.Member
  defstruct name: nil, members: []

  def from_code_docs(name, docs) do
    case docs do
      {:docs_v1, _anno, _language, _format, :hidden, _meta, _doc_content} ->
        {:error, :hidden}

      {:docs_v1, _anno, _language, _format, _moduledoc, _meta, doc_content} ->
        {:ok,
         %__MODULE__{
           name: name,
           members: Enum.map(doc_content, &Member.from_code_docs(&1))
         }}

      _ ->
        {:error, :unexpected_docs}
    end
  end
end
