defmodule ShoppingList.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ShoppingListWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ShoppingList.PubSub},
      # Start the Endpoint (http/https)
      ShoppingListWeb.Endpoint,
      # Start a worker by calling: ShoppingList.Worker.start_link(arg)
      # {ShoppingList.Worker, arg}
      ShoppingList.ItemList
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShoppingList.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ShoppingListWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
