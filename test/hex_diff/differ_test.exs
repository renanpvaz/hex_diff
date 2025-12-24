defmodule HexDiff.DifferTest do
  use ExUnit.Case

  alias HexDiff.Differ
  alias HexDiff.Diff
  alias HexDiff.Diff.Typespec
  alias HexDiff.AST.Module
  alias HexDiff.AST.Member

  describe "compare/2" do
    @tag :wip
    test "identifies deeply nested typespec changes" do
      {:ok, t1} =
        Code.string_to_quoted("""
        @spec add(integer(), number()) :: number()
        """)

      {:ok, t2} =
        Code.string_to_quoted("""
        @spec add(number(), number()) :: number()
        """)

      new = %Module{
        name: "Math",
        members: [
          %Member{
            name: "add",
            type: :function,
            arity: 2,
            typespec: t1
          }
        ]
      }

      old = %Module{
        name: "Math",
        members: [
          %Member{
            name: "add",
            type: :function,
            arity: 2,
            typespec: t2
          }
        ]
      }

      assert %Diff{changed: [module_diff]} = Differ.compare([new], [old])
      assert %Diff{changed: [change]} = module_diff
      assert {%Member{name: "add"}, [%Typespec{change: {:integer, :number}}, :unchanged]} = change
    end
  end

  describe "compare_typespecs/2" do
    test "errors when comparing spec to type" do
      {:ok, t1} =
        Code.string_to_quoted("""
        @spec add(integer(), number()) :: number()
        """)

      {:ok, t2} =
        Code.string_to_quoted("""
        @type my_type() :: number()
        """)

      assert {:error, :type_mismatch} = Differ.compare_typespecs(t1, t2)
    end

    test "errors when comparing different members" do
      {:ok, t1} =
        Code.string_to_quoted("""
        @spec add(number(), number()) :: number()
        """)

      {:ok, t2} =
        Code.string_to_quoted("""
        @spec sum(number(), number()) :: number()
        """)

      assert {:error, :name_mismatch} = Differ.compare_typespecs(t1, t2)
    end

    test "errors on different arity" do
      {:ok, t1} =
        Code.string_to_quoted("""
        @spec add(number(), number()) :: number()
        """)

      {:ok, t2} =
        Code.string_to_quoted("""
        @spec add(number()) :: number()
        """)

      assert {:error, :arity_mismatch} = Differ.compare_typespecs(t1, t2)
    end

    test "identifies simple type changes" do
      {:ok, t1} =
        Code.string_to_quoted("""
        @spec add(number(), number()) :: number()
        """)

      {:ok, t2} =
        Code.string_to_quoted("""
        @spec add(float(), number()) :: number()
        """)

      assert {:ok, [change, :unchanged]} = Differ.compare_typespecs(t1, t2)
      assert %Typespec{change: {:number, :float}, new_spec: _, old_spec: _} = change
    end

    test "metadata does not influence result" do
      {:ok, t1} =
        Code.string_to_quoted("""
        @spec add(number(), number()) :: number()
        """)

      {:ok, t2} =
        Code.string_to_quoted("""
          @spec add(
            number(), 
            number()
          ) :: number()
        """)

      assert {:ok, [:unchanged, :unchanged]} = Differ.compare_typespecs(t1, t2)
    end
  end
end
