defmodule Supabase.Application do
  @moduledoc false

  use Application

  alias Supabase.Storage

  @finch_opts [name: Supabase.Finch, pools: %{:default => [size: 10]}]

  @impl true
  def start(_start_type, _args) do
    children = [
      {Finch, @finch_opts},
      Supabase.ClientSupervisor,
      Supabase.ClientRegistry,
      if(start_cache?(), do: {Storage.Cache, cache_max_size: cache_max_size()}),
      if(start_cache?(), do: {Storage.CacheSupervisor, reload_interval: reload_interval()})
    ]

    opts = [strategy: :one_for_one, name: Supabase.Supervisor]

    children
    |> Enum.reject(&is_nil/1)
    |> Supervisor.start_link(opts)
  end

  defp cache_max_size do
    Application.get_env(:supabase, :cache_max_size, 100)
  end

  defp start_cache? do
    Application.get_env(:supabase, :cache_buckets?)
  end

  defp reload_interval do
    Application.get_env(:supabase, :reload_interval, 60_000)
  end
end
