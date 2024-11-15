defmodule Notifi.MixProject do
  use Mix.Project

  def project do
    [
      app: :notifi,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Notifi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quantum, "~> 3.5"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:mongodb_driver, "~> 1.5.0"},
      {:tzdata, "~> 1.1"},
      {:mock, "~> 0.3.8", only: :test}
    ]
  end
end
