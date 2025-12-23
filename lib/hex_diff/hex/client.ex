defmodule HexDiff.Hex.Client do
  @callback fetch_source(package :: String.t(), version :: String.t()) ::
              {:ok, String.t()} | {:error, any()}

  @callback fetch_docs(package :: String.t(), version :: String.t()) ::
              {:ok, String.t()} | {:error, any()}
end
