defmodule Supabase.Storage.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/zoedsoupe/supabase_storage"

  def project do
    [
      app: :supabase_storage,
      version: @version,
      elixir: "~> 1.15",
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
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
      {:supabase_potion, umbrella_dep(Mix.env())},
      {:ex_doc, ">= 0.0.0", runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end

  defp umbrella_dep(:prod), do: "~> 0.2"
  defp umbrella_dep(_), do: [in_umbrella: true]

  defp package do
    %{
      name: "supabase_storage",
      licenses: ["MIT"],
      contributors: ["zoedsoupe"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/supabase_storage"
      },
      files: ~w[lib mix.exs README.md LICENSE]
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
