defmodule GRPCStatsd.MixProject do
  use Mix.Project

  def project do
    [
      app: :grpc_statsd,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: "statsd interceptor/middleware for https://github.com/elixir-grpc/grpc",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    %{
      maintainers: ["Bing Han"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elixir-grpc/grpc-statsd"},
      files: ~w(.formatter.exs mix.exs lib)
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:statix, ">= 0.0.0", optional: true},
      {:grpc, ">= 0.0.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
