defmodule HexDiff.Hex.Client do
  @callback fetch_source(package :: String.t(), version :: String.t()) ::
              {:ok, Path.t()} | {:error, any()}

  @callback fetch_docs(package :: String.t(), version :: String.t(), dest :: Path.t()) ::
              {:ok, Path.t()} | {:error, any()}
end
