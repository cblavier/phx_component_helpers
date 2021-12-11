defmodule PhxComponentHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_component_helpers,
      version: "0.12.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "Making development of Phoenix LiveView live_components easier.",
      package: package(),
      name: "phx_component_helpers",
      source_url: "https://github.com/cblavier/phx_component_helpers",
      docs: [
        main: "PhxComponentHelpers",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, ">= 3.0.0"},
      {:phoenix_live_view, ">= 0.15.0", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cblavier/phx_component_helpers"}
    ]
  end
end
