defmodule Supabase.Potion.MixProject do
  use Mix.Project

  @version "0.3.6"
  @source_url "https://github.com/zoedsoupe/supabase"

  def project do
    [
      app: :supabase_potion,
      version: @version,
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description()
    ]
  end

  def application do
    [
      mod: {Supabase.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:finch, "~> 0.16"},
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.10"},
      {:ex_doc, ">= 0.0.0", runtime: false, only: [:dev, :prod]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_potion"
      },
      files: ~w[lib mix.exs README.md LICENSE]
    }
  end

  defp docs do
    [
      main: "Supabase",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    Complete Elixir client for Supabase.
    """
  end
end
