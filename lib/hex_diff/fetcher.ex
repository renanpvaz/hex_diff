defmodule HexDiff.Fetcher do
  # https://github.com/hexpm/hex/blob/v2.0.6/lib/hex/api/package.ex
  # use hex API to search package

  # Mix.SCM.Git.checkout([
  # checkout: "./httpoison", 
  # dest: "httpoison", 
  # git: "git@github.com:edgurgel/httpoison.git", tag: "v2.2.1"
  # ])

  # checks out package locally
  # run(:httpoison, "v2.2.1")

  def checkout(name, url, tag) do
    path = Path.join(["packages", name, tag])
    Mix.SCM.Git.checkout(checkout: path, dest: path, git: url, tag: tag)
  end
end
