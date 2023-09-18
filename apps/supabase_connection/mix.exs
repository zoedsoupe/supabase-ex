defmodule Supabase.Connection.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zoedsoupe/supabase/tree/main/apps/supabase_connection"

  def project do
    [
      app: :supabase_connection,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Supabase.Connection.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      if(Mix.env() == :prod,
        do: {:supabase_types, "~> 0.1"},
        else: {:supabase_types, in_umbrella: true}
      ),
      {:ex_doc, ">= 0.0.0", runtime: false}
    ]
  end

  defp package do
    %{
      name: "supabase_connection",
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_connection"
      },
      files: ~w[lib mix.exs README.md ../../LICENSE]
    }
  end

  defp docs do
    [
      main: "Supabase.Connection",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    Defines a Supabase Connection for usage in the Supabase Potion.
    """
  end
end
