defmodule Supabase.Types.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/zoedsoupe/supabase/tree/main/apps/supabase_types"

  def project do
    [
      app: :supabase_types,
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
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      name: "supabase_types",
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_types"
      },
      files: ~w[lib mix.exs README.md ../../LICENSE]
    }
  end

  defp docs do
    [
      main: "Supabase Types",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    Define some common entities and types for Supabase.
    """
  end
end
