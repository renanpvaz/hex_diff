defmodule HexDiff.Resolvers.ScraperTest do
  use ExUnit.Case

  alias HexDiff.Resolvers.Scraper

  import Mox

  describe "resolve/2" do
    for version <- ["1.4.4", "1.2.2", "1.0.0"] do
      test "parses documents from different exdoc versions (jason v#{version})" do
        expect(HexDiff.Hex.ClientMock, :fetch_docs, fn _, _ ->
          "../test/fixtures/jason-#{unquote(version)}-docs"
        end)

        assert Scraper.resolve("jason", unquote(version))
      end
    end
  end
end
