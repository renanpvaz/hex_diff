defmodule HexDiff.ModuleMap do
  defstruct modules: %{}

  @default_options [ignore_hidden: true]

  def new() do
    %__MODULE__{}
  end

  def names(map) do
    Map.keys(map.modules)
  end

  def get(map, name) do
    Map.get(map.modules, name)
  end

  def put_from_code_docs(module_map, name, docs, opts \\ @default_options) do
    {:docs_v1, _anno, _language, _format, moduledoc, _meta, doc_content} = docs

    if ignore_hidden?(moduledoc, opts) do
      module_map
    else
      %__MODULE__{modules: Map.put(module_map.modules, name, find_public_members(doc_content))}
    end
  end

  defp find_public_members(docs_list) do
    docs_list
    |> Enum.reject(fn
      {_def, _, _, :hidden, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {member, _, _, _, _} -> member end)
  end

  defp ignore_hidden?(moduledoc, opts) do
    moduledoc == :hidden and opts[:ignore_hidden]
  end
end
