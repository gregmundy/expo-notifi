import Config

config :notifi, :meet_steve,
  name: :meet_steve,
  api_base_url: System.get_env("STEVE_API_URL"),
  api_key: System.get_env("STEVE_API_KEY")
