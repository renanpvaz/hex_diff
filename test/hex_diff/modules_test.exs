defmodule HexDiff.ModulesTest do
  use ExUnit.Case
  alias HexDiff.Modules

  describe "diff/2" do
    test "detects additions" do
      defmodule A do
      end

      defmodule B do
        def run(_a) do
          :ok
        end
      end

      assert %{additions: [{:run, 1}]} = Modules.diff(A, B)
    end

    test "detects removals" do
      defmodule A do
        def run(_a) do
          :ok
        end
      end

      defmodule B do
      end

      assert %{removals: [{:run, 1}]} = Modules.diff(A, B)
    end

    test "detects arity changes" do
      defmodule A do
        def run(_a) do
          :ok
        end
      end

      defmodule B do
        def run(_a, _b) do
          :ok
        end
      end

      assert %{removals: [{:run, 1}], additions: [{:run, 2}]} = Modules.diff(A, B)
    end
  end
end
