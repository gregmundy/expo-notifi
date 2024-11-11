import Config
alias Notifi.Tasks.{TransactionReminder, Heartbeat}

config :notifi, Notifi.Scheduler,
  jobs: [
    {"* * * * *", {Heartbeat, :send, []}},
    {"* * * * *", {TransactionReminder, :send, []}}
  ]

config :notifi, :mongo,
  name: :mongo,
  url: "mongodb://mongo:27017,mongo2:27018,mongo3:27019/meetsteve_dev?replicaSet=rs0",
  pool_size: 3
