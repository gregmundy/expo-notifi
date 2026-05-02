import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :notifi, Notifi.Scheduler,
  timezone: "America/New_York",
  jobs: [
    {"*/30 * * * *", {Notifi.ReceiptChecker, :check_receipts, []}}
  ]

config :httpoison, :hackney, timeout: 10_000, recv_timeout: 15_000
