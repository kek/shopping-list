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

  def each(list_name, fun), do: GenServer.call(__MODULE__, {:each, list_name, fun})

  def check(list_name, id), do: GenServer.call(__MODULE__, {:check, list_name, id})

  def uncheck(list_name, id), do: GenServer.call(__MODULE__, {:uncheck, list_name, id})

  def add(list_name, name), do: GenServer.call(__MODULE__, {:add, list_name, name})

  def remove(list_name, id), do: GenServer.call(__MODULE__, {:remove, list_name, id})

  def all(list_name), do: GenServer.call(__MODULE__, {:all, list_name})

  def list_of_lists(), do: GenServer.call(__MODULE__, {:list_of_lists})

  def handle_info({:save}, state) do
    save_items(state)
    Process.send_after(self(), {:save}, 5000)
    {:noreply, state}
  end

  def handle_call({:each, list_name, fun}, _from, state) do
    list =
      Map.get(state, list_name)
      |> Enum.map(fun)

    {:reply, Map.put(state, list_name, list), state}
  end

  def handle_call({:add, list_name, name}, _from, state) do
    list = Map.get(state, list_name, []) ++ [Item.new(name)]

    {:reply, :ok, Map.put(state, list_name, list)}
  end

  def handle_call({:remove, list_name, id}, _from, state) do
    list =
      state
      |> Map.get(list_name)
      |> Enum.flat_map(fn item ->
        if item.id == id do
          []
        else
          [item]
        end
      end)

    {:reply, :ok, Map.put(state, list_name, list)}
  end

  def handle_call({:check, list_name, id}, _from, state) do
    list =
      state
      |> Map.get(list_name)
      |> Enum.map(fn item ->
        if item.id == id do
          %{item | checked: true}
        else
          item
        end
      end)

    {:reply, :ok, Map.put(state, list_name, list)}
  end

  def handle_call({:uncheck, list_name, id}, _from, state) do
    list =
      state
      |> Map.get(list_name)
      |> Enum.map(fn item ->
        if item.id == id do
          %{item | checked: false}
        else
          item
        end
      end)

    {:reply, :ok, Map.put(state, list_name, list)}
  end

  def handle_call({:all, list_name}, _from, state) do
    {:reply, Map.get(state, list_name, []), state}
  end

  def handle_call({:list_of_lists}, _from, state) do
    {:reply, Map.keys(state), state}
  end

  defp load_items do
    case File.open(storage_file(), [:read]) do
      {:ok, file} ->
        Logger.debug("Reading items")

        json = IO.read(file, :all)
        {:ok, data} = Jason.decode(json)

        Enum.map(data, fn {list_name, list} ->
          list =
            Enum.map(list, fn %{"id" => id, "name" => name, "checked" => checked} ->
              %Item{id: id, name: name, checked: checked}
            end)

          {list_name, list}
        end)
        |> Map.new()

      {:error, :enoent} ->
        Logger.debug("Populating default items")
        %{}
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
