defmodule Supabase.ClientSupervisor do
  @moduledoc """
  A supervisor for all Clients. In most cases this should be started
  automatically by the application supervisor and be used mainly by
  the `Supabase` module, available on `:supabase_potion` application.

  Although if you want to manage Clients manually, you can leverage
  this module to start and stop Clients dynamically. To start the supervisor
  manually, you need to add it to your supervision tree:

      defmodule MyApp.Application do
        use Application

        def start(_type, _args) do
          children = [
            {Supabase.ClientSupervisor, []}
          ]

          opts = [strategy: :one_for_one, name: MyApp.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end

  And then use the Supervisor to start custom clients:

      iex> Supabase.ClientSupervisor.start_child({Supabase.Client, opts})
      {:ok, #PID<0.123.0>}
  """

  use DynamicSupervisor

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(init) do
    DynamicSupervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
