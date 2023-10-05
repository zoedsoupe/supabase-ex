defmodule Supabase.ClientRegistry do
  @moduledoc false

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
