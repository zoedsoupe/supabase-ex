defmodule Supabase.Connection.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [Supabase.ConnectionSupervisor]

    opts = [strategy: :one_for_one, name: Supabase.Connection.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
