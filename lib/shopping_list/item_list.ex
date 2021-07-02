defmodule ShoppingList.ItemList do
  use GenServer
  alias ShoppingList.Item
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Process.flag(:trap_exit, true)
    Process.send_after(self(), {:save}, 5000)
    {:ok, load_items()}
  end

  def terminate(reason, state) do
    Logger.debug("Terminating for #{inspect(reason)} with #{inspect(state)}")
    save_items(state)
  end

  def each(fun), do: GenServer.call(__MODULE__, {:each, fun})

  def check(id), do: GenServer.call(__MODULE__, {:check, id})

  def uncheck(id), do: GenServer.call(__MODULE__, {:uncheck, id})

  def add(name), do: GenServer.call(__MODULE__, {:add, name})

  def remove(id), do: GenServer.call(__MODULE__, {:remove, id})

  def all(), do: GenServer.call(__MODULE__, {:all})

  def handle_info({:save}, state) do
    Logger.debug("Saving")
    save_items(state)
    Process.send_after(self(), {:save}, 5000)
    {:noreply, state}
  end

  def handle_call({:each, fun}, _from, state) do
    {:reply, Enum.map(state, fun), state}
  end

  def handle_call({:add, name}, _from, state) do
    {:reply, :ok, state ++ [Item.new(name)]}
  end

  def handle_call({:remove, id}, _from, state) do
    state =
      state
      |> Enum.flat_map(fn item ->
        if item.id == id do
          []
        else
          [item]
        end
      end)

    {:reply, :ok, state}
  end

  def handle_call({:check, id}, _from, state) do
    state =
      state
      |> Enum.map(fn item ->
        if item.id == id do
          %{item | checked: true}
        else
          item
        end
      end)

    {:reply, :ok, state}
  end

  def handle_call({:uncheck, id}, _from, state) do
    state =
      state
      |> Enum.map(fn item ->
        if item.id == id do
          %{item | checked: false}
        else
          item
        end
      end)

    {:reply, :ok, state}
  end

  def handle_call({:all}, _from, state) do
    {:reply, state, state}
  end

  defp load_items do
    case File.open(storage_file(), [:read]) do
      {:ok, file} ->
        Logger.debug("Reading items")

        json = IO.read(file, :all)
        {:ok, data} = Jason.decode(json)

        Enum.map(data, fn %{"id" => id, "name" => name, "checked" => checked} ->
          %Item{id: id, name: name, checked: checked}
        end)
        |> IO.inspect(label: "items")

      {:error, :enoent} ->
        Logger.debug("Populating default items")
        []
    end
  end

  defp save_items(state) do
    {:ok, file} = File.open(storage_file(), [:write])
    {:ok, json} = Jason.encode(state)
    :ok = IO.write(file, json)
    :ok = File.close(file)
  end

  defp storage_file() do
    Application.get_env(:shopping_list, :storage)
  end
end
