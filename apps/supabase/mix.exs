defmodule Supabase.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zoedsoupe/supabase"

  def project do
    [
      app: :supabase,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
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
      {:ecto, "~> 3.10"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ] ++ child_deps(Mix.env())
  end

  defp child_deps(:prod) do
    [
      {:supabase_types, "~> 0.1"},
      {:supabase_connection, "~> 0.1"},
      {:supabase_fetcher, "~> 0.1"},
      {:supabase_storage, "~> 0.1"}
    ]
  end

  defp child_deps(_) do
    [
      {:supabase_types, in_umbrella: true},
      {:supabase_connection, in_umbrella: true},
      {:supabase_fetcher, in_umbrella: true},
      {:supabase_storage, in_umbrella: true}
    ]
  end

  defp package do
    %{
      name: "supabase_potion",
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_potion"
      },
      files: ~w[lib mix.exs README.md ../../LICENSE]
    }
  end

  defp docs do
    [
      main: "Supabase Potion",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    Complete Elixir client for Supabase.
    """
  end
end
