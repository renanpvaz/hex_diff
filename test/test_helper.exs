Mox.defmock(HexDiff.Hex.ClientMock, for: HexDiff.Hex.Client)

Application.put_env(:hex_diff, :hex_client, HexDiff.Hex.ClientMock)

ExUnit.start()
