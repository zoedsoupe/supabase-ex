defmodule Supabase.ClientRegistry do
  @moduledoc """
  Registry for the Supabase multiple Clients. This registry is used to
  register and lookup the Supabase Clients defined by the user.

  This Registry is used by the `Supabase.ClientSupervisor` to register and
  any `Supabase.Client` that is defined. That way, the `Supabase.ClientSupervisor`
  can lookup the `Supabase.Client` by name and start it if it is not running.

  ## Usage

  This Registry is used internally by the `Supabase.Application` and should
  start automatically when the application starts.
  """

  def start_link(_) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def named(key) when is_atom(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def register(key) when is_atom(key) do
    Registry.register(__MODULE__, key, nil)
  end

  def lookup(key) when is_atom(key) do
    case Registry.lookup(__MODULE__, key) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end
end
