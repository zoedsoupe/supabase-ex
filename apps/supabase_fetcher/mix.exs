defmodule Supabase.Fetcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :supabase_fetcher,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:jason, "~> 1.4"}
    ]
  end
end
