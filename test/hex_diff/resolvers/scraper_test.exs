defmodule HexDiff.Resolvers.ScraperTest do
  use ExUnit.Case

  alias HexDiff.Resolvers.Scraper

  import Mox

  describe "resolve/2" do
    for {version, module_count} <- [
          {"1.4.4", 10},
          {"1.2.2", 8},
          {"1.0.0", 7}
        ] do
      test "parses documents from different exdoc versions (jason v#{version})" do
        expect(HexDiff.Hex.ClientMock, :fetch_docs, fn _, _, _ ->
          {:ok, "test/fixtures/jason-#{unquote(version)}-docs"}
        end)

        assert {:ok, modules} = Scraper.resolve("jason", unquote(version))
        assert length(modules) == unquote(module_count)
      end
    end

    test "correctly identifies functions" do
      expect(HexDiff.Hex.ClientMock, :fetch_docs, fn _, _, _ ->
        {:ok, "test/fixtures/jason-1.4.4-docs"}
      end)

      assert {:ok, modules} = Scraper.resolve("jason", "1.4.4")
      assert {_, signatures} = Enum.find(modules, &(elem(&1, 0) == "Jason.Encoder"))
      assert {"function", _} = Enum.find(signatures, &(elem(&1, 1) =~ "encode("))
    end

    test "correctly identifies typespecs" do
      expect(HexDiff.Hex.ClientMock, :fetch_docs, fn _, _, _ ->
        {:ok, "test/fixtures/jason-1.4.4-docs"}
      end)

      assert {:ok, modules} = Scraper.resolve("jason", "1.4.4")
      assert {_, signatures} = Enum.find(modules, &(elem(&1, 0) == "Jason.Encoder"))
      assert {"type", _} = Enum.find(signatures, &(elem(&1, 1) == "t()"))
    end

    test "correctly identifies macros" do
      expect(HexDiff.Hex.ClientMock, :fetch_docs, fn _, _, _ ->
        {:ok, "test/fixtures/jason-1.4.4-docs"}
      end)

      assert {:ok, modules} = Scraper.resolve("jason", "1.4.4")
      assert {_, signatures} = Enum.find(modules, &(elem(&1, 0) == "Jason.Sigil"))
      assert {"macro", _} = Enum.find(signatures, &(elem(&1, 1) =~ "sigil"))
    end
  end
end
