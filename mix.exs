defmodule Lettuce.MixProject do
  use Mix.Project

  def project do
    [
      app: :lettuce,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir code reloader, watch files, recompile and restart.",
      package: package(),
      dialyzer: [plt_add_deps: :apps_direct],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Lettuce.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Josep Lluis Giralt D'Lacoste"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/gilacost/lettuce"}
    ]
  end
end
