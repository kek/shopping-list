defmodule ShoppingListWeb.PageLive do
  use ShoppingListWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, items: items())}
  end

  @impl true

  def handle_event("change", %{"_target" => ["check", id], "check" => boxes}, socket) do
    on = boxes[id] == "on"
    Logger.debug("Checked item #{id} to #{on}")
    {:noreply, assign(socket, items: items())}
  end

  def handle_event("change", %{"_target" => ["check", id]}, socket) do
    on = false
    Logger.debug("Checked item #{id} to #{on}")
    {:noreply, assign(socket, items: items())}
  end

  def handle_event("change", whatever, socket) do
    Logger.debug("whatever is #{inspect(whatever)}")
    {:noreply, assign(socket, items: items())}
  end

  def handle_event("add", whatever, socket) do
    Logger.debug("add #{inspect(whatever)}")
    {:noreply, assign(socket, items: items())}
  end

  defp items() do
    [{1, "tomatis"}, {2, "potatisk"}, {3, "kaosalis"}]
  end
end
