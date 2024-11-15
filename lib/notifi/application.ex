defmodule Notifi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    mongo_config = Application.get_env(:notifi, :mongo)

    children = [
      Notifi.ReceiptCache,
      Notifi.Scheduler,
      {Mongo, mongo_config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Notifi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
