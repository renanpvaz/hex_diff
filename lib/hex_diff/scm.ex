defmodule HexDiff.SCM do
  alias HexDiff.AST
  # dest
  # origin
  # tag
  # name
  def checkout(opts) do
    File.mkdir_p!(opts[:dest])

    File.cd!(opts[:dest], fn ->
      git!(["clone", "--depth=1", opts[:origin]])
    end)
  end

  def read() do
    Path.wildcard("./packages/**/*.ex")
    |> Enum.map(&File.read!/1)
    |> Enum.map(&Code.string_to_quoted!/1)
    |> AST.parse()
  end

  defp default_into() do
    case Mix.shell() do
      Mix.Shell.IO -> IO.stream()
      _ -> ""
    end
  end

  defp cmd_opts(opts) do
    case File.cwd() do
      {:ok, cwd} -> Keyword.put(opts, :cd, cwd)
      _ -> opts
    end
  end

  def git!(args, into \\ default_into()) do
    opts = cmd_opts(into: into, stderr_to_stdout: true)

    try do
      System.cmd("git", args, opts)
    catch
      :error, :enoent ->
        Mix.raise(
          "Error fetching/updating Git repository: the \"git\" " <>
            "executable is not available in your PATH. Please install " <>
            "Git on this machine or pass --no-deps-check if you want to " <>
            "run a previously built application on a system without Git."
        )
    else
      {response, 0} ->
        response

      {response, _} when is_binary(response) ->
        Mix.raise("Command \"git #{Enum.join(args, " ")}\" failed with reason: #{response}")

      {_, _} ->
        Mix.raise("Command \"git #{Enum.join(args, " ")}\" failed")
    end
  end
end
