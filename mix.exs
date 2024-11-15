defmodule Notifi.MixProject do
  use Mix.Project

  def project do
    [
      app: :notifi,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        notifi: [
          include_erts: true,
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {Notifi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quantum, "~> 3.5"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:tzdata, "~> 1.1"},
      {:mock, "~> 0.3.8", only: :test}
    ]
  end
end
