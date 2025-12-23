defmodule HexDiff.Hex.HexCore do
  alias HexDiff.Hex.Client

  @behaviour Client

  @impl Client
  def fetch_source(name, version) do
    qualified_name = "#{name}-#{version}"

    {:ok, {200, _, tarball}} =
      :hex_repo.get_tarball(:hex_core.default_config(), name, version)

    {:ok, %{outer_checksum: _checksum, metadata: _metadata}} =
      :hex_tarball.unpack(tarball, String.to_charlist(qualified_name))

    Path.expand(qualified_name)
  end

  @impl Client
  def fetch_docs(name, version) do
    path = "#{name}-#{version}/docs"

    {:ok, {200, _, tarball}} =
      :hex_repo.get_docs(:hex_core.default_config(), name, version)

    :ok = :hex_tarball.unpack_docs(tarball, String.to_charlist(path))

    Path.expand(path)
  end
end
