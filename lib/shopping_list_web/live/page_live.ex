defmodule ShoppingListWeb.PageLive do
  use ShoppingListWeb, :live_view
  alias ShoppingList.ItemList
  require Logger

  @impl true
  def mount(%{"list" => list_name}, _session, socket) do
    Logger.debug("Mount #{list_name}")
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    {:ok,
     assign(socket,
       items: ItemList.all(list_name),
       list_name: list_name,
       lists: ItemList.list_of_lists()
     )}
  end

  def mount(params, session, socket) do
    mount(Map.put(params, "list", "shopping"), session, socket)
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end

  @impl true
  def handle_event("change", %{"_target" => ["check", id], "check" => boxes}, socket) do
    if boxes[id] == "on" do
      Logger.debug("check #{inspect(id)}")
      ItemList.check(socket.assigns.list_name, id)
    else
      Logger.debug("uncheck #{inspect(id)}")
      ItemList.uncheck(socket.assigns.list_name, id)
    end

    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end

  def handle_event("change", %{"_target" => ["check", id]}, socket) do
    Logger.debug("uncheck #{inspect(id)}")
    ItemList.uncheck(socket.assigns.list_name, id)
    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end

  def handle_event("change", whatever, socket) do
    Logger.debug("ignoring change event #{inspect(whatever)}")
    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end

  def handle_event("add", %{"new" => ""}, socket) do
    Logger.debug("Empty new event")
    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end

  def handle_event("add", %{"new" => name} = event, socket) do
    Logger.debug("Adding #{name}. #{inspect(event)}")
    ItemList.add(socket.assigns.list_name, name)
    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end

  def handle_event("remove", %{"item-id" => id} = event, socket) do
    Logger.debug("Removing #{id}. #{inspect(event)}")
    ItemList.remove(socket.assigns.list_name, id)
    {:noreply, assign(socket, items: ItemList.all(socket.assigns.list_name))}
  end
end
