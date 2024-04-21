defmodule Supabase.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    name = Keyword.get(opts, :name, Supabase.Supervisor)
    strategy = Keyword.get(opts, :strategy, :one_for_one)
    opts = [name: name, strategy: strategy]
    children = [Supabase.ClientRegistry, Supabase.ClientSupervisor]

    Supervisor.init(children, opts)
  end

end
