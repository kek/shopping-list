defmodule ShoppingList.Item do
  defstruct [:id, :name, :checked]

  def new(name) do
    %__MODULE__{id: generate_id(), name: name, checked: false}
  end

  defp generate_id do
    Integer.to_string(:rand.uniform(4_294_967_296), 32) <>
      Integer.to_string(:rand.uniform(4_294_967_296), 32)
  end
end
