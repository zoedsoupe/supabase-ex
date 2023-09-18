defmodule Supabase.Fetcher.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zoedsoupe/supabase/tree/main/apps/supabase_fetcher"

  def project do
    [
      app: :supabase_fetcher,
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
      mod: {Supabase.Fetcher.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:finch, "~> 0.16"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", runtime: false}
    ]
  end

  defp package do
    %{
      name: "supabase_fetcher",
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_fetcher"
      },
      files: ~w[lib mix.exs README.md ../../LICENSE]
    }
  end

  defp docs do
    [
      main: "Supabase.Fetcher",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    A customized HTTP client for Supabase. Mainly used in Supabase Potion.
    """
  end
end
