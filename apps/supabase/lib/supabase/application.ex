defmodule Supabase.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_start_type, _args) do
    children = [Supabase.ClientSupervisor]
    opts = [strategy: :one_for_one, name: Supabase.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
