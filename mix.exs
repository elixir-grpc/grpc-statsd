defmodule GrpcStatsd.MixProject do
  use Mix.Project

  def project do
    [
      app: :grpc_statsd,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:statix, ">= 0.0.0", optional: true},
      {:grpc, ">= 0.0.0", optional: true}
    ]
  end
end
