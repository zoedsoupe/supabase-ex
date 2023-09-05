defmodule Supabase.Fetcher.Application do
  @moduledoc "Simple Supervisor to manage a Finch pool"

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: Supabase.Finch, pools: %{:default => [size: 10]}}
    ]

    opts = [strategy: :one_for_one, name: Supabase.Fetch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
