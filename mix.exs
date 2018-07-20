defmodule NknClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :nkn_client,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :jsonrpc2, :poison, :hackney, :websockex],
      mod: {NknClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jsonrpc2, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:hackney, "~> 1.7"},
      {:websockex, "~> 0.4.0"},
      {:gen_stage, "~> 0.14"}
    ]
  end
end
