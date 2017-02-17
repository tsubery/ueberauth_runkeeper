defmodule UeberauthRunkeeper.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @url "https://github.com/tsubery/ueberauth_runkeeper"

  def project do
    [app: :ueberauth_runkeeper,
     version: @version,
     name: "Ueberauth Runkeeper Strategy",
     package: package(),
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     description: description(),
     deps: deps(),
     docs: docs()]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [{:ueberauth, "~> 0.4"},
     {:oauth2, "~> 0.8"},
     {:poison, "~> 3.0"},
     {:ex_doc, "~> 0.3", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Uberauth strategy for Runkeeper authentication."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Gal Tsubery"],
     licenses: ["Apache 2.0"],
     links: %{
       "GitHub": @url,
       "Runkeeper": "https://runkeeper.com"
     }]
  end
end
