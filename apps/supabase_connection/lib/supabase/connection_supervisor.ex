defmodule Supabase.ConnectionSupervisor do
  @moduledoc """
  A supervisor for all connections. In most cases this should be started
  automatically by the application supervisor and be used mainly by
  the `Supabase` module, availaton on `:supabase_potion` application.

  Although if you want to manage connections manually, you can leverage
  this module to start and stop connections dynamically. To see how to start
  a single connection manually, check `Supabase.Connection` module docs.

  ## Examples

      iex> Supabase.ConnectionSupervisor.start_link([])
      {:ok, #PID<0.123.0>}

      iex> Supabase.ConnectionSupervisor.start_child({Supabase.Connection, opts})
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
