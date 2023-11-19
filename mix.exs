defmodule Supabase.MixProject do
  use Mix.Project

  def project do
    [
      name: :supabase,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    []
  end
end
