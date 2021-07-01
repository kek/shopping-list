defmodule ShoppingList.ItemList do
  use GenServer
  alias ShoppingList.Item

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, load_items()}
  end

  def each(fun), do: GenServer.call(__MODULE__, {:each, fun})

  def check(id), do: GenServer.call(__MODULE__, {:check, id})

  def uncheck(id), do: GenServer.call(__MODULE__, {:uncheck, id})

  def add(name), do: GenServer.call(__MODULE__, {:add, name})

  def remove(id), do: GenServer.call(__MODULE__, {:remove, id})

  def all(), do: GenServer.call(__MODULE__, {:all})

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
    [
      Item.new("tomatillo"),
      Item.new("spagati"),
      Item.new("fantasini")
    ]
  end
end
