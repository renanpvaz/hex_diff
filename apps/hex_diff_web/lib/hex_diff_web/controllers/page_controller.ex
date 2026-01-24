defmodule HexDiffWeb.PageController do
  use HexDiffWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
