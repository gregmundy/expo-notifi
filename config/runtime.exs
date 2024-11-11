import Config

config :notifi, :mongo,
  name: :mongo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 3
