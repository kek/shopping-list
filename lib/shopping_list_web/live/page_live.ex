defmodule ShoppingListWeb.PageLive do
  use ShoppingListWeb, :live_view
  alias ShoppingList.ItemList
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, items: ItemList.all())}
  end

  @impl true
  def handle_event("change", %{"_target" => ["check", id], "check" => boxes}, socket) do
    if boxes[id] == "on" do
      ItemList.check(id)
    else
      ItemList.uncheck(id)
    end

    {:noreply, assign(socket, items: ItemList.all())}
  end

  def handle_event("change", %{"_target" => ["check", id]}, socket) do
    ItemList.uncheck(id)
    {:noreply, assign(socket, items: ItemList.all())}
  end

  def handle_event("change", whatever, socket) do
    Logger.debug("unknown change event is #{inspect(whatever)}")
    {:noreply, assign(socket, items: ItemList.all())}
  end

  def handle_event("add", %{"new" => name}, socket) do
    Logger.debug("add #{name}")
    ItemList.add(name)
    {:noreply, assign(socket, items: ItemList.all())}
  end
end
