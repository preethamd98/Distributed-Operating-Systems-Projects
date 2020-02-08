defmodule InstachatWeb.PageController do
  use InstachatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
