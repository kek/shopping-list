defmodule ShoppingListWeb.PageLiveTest do
  use ShoppingListWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "html"
    assert render(page_live) =~ "div data-phx-main"
  end
end
