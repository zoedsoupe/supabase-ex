defmodule Supabase.Storage.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zoedsoupe/supabase/tree/main/apps/supabase_storage"

  def project do
    [
      app: :supabase_storage,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Supabase.Storage.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:ex_doc, ">= 0.0.0", runtime: false}
    ] ++ child_deps(Mix.env())
  end

  defp child_deps(:prod) do
    [
      {:supabase_fetcher, "~> 0.1"},
      {:supabase_connection, "~> 0.1"}
    ]
  end

  defp child_deps(_) do
    [
      {:supabase_fetcher, in_umbrella: true},
      {:supabase_connection, in_umbrella: true}
    ]
  end

  defp package do
    %{
      name: "supabase_storage",
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_storage"
      },
      files: ~w[lib mix.exs README.md ../../LICENSE]
    }
  end

  defp docs do
    [
      main: "Supabase.Storage",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    High level Elixir client for Supabase Storage.
    """
  end
end
