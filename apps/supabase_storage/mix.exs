defmodule Supabase.Storage.MixProject do
  use Mix.Project

  def project do
    [
      app: :supabase_storage,
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
      extra_applications: [:logger],
      mod: {Supabase.Storage.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:supabase_fetcher, in_umbrella: true}
    ]
  end
end
