import Config

secret_key_base =
  if config_env() == :prod do
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """
  else
    "6z/v1/06XBINk4kghypkpB+J1awjsJmWhuiJMey0JOdjXbLc3gNWscgez8PV3V+Q"
  end

host =
  if config_env() == :prod do
    System.fetch_env!("WEB_HOST")
  else
    "localhost"
  end

port = String.to_integer(System.get_env("PORT") || "4000")

config :shopping_list, ShoppingListWeb.Endpoint,
  url: [host: host, port: port],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: port,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base,
  server: true

config :shopping_list,
  storage: System.get_env("STORAGE", "/tmp/shopping-list.json")
