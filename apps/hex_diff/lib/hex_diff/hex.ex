defmodule HexDiff.Hex do
  def fetch_source(package, version) do
    client().fetch_source(package, version)
  end

  def fetch_docs(package, version, dest) do
    client().fetch_docs(package, version, dest)
  end

  defp client do
    Application.get_env(:hex_diff, :hex_client, HexDiff.Hex.HexCore)
  end
end
