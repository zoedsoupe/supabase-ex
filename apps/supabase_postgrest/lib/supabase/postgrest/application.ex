defmodule Supabase.PostgREST.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [Supabase.PostgREST.Repo, Supabase.PostgREST.EctoAdapter.Connection]

    opts = [strategy: :one_for_one, name: Supabase.PostgREST.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
