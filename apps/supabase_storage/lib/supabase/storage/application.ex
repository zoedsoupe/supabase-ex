defmodule Supabase.Storage.Application do
  @moduledoc false

  use Application

  @default_cache_size 100
  @default_buckets_reload_interval 60_000

  @impl true
  def start(_type, _args) do
    children = [
      if(start_cache?(), do: {Storage.Cache, cache_max_size: cache_max_size()}),
      if(start_cache?(), do: {Storage.CacheSupervisor, reload_interval: reload_interval()})
    ]

    opts = [strategy: :one_for_one, name: Supabase.Storage.Supervisor]

    children
    |> Enum.reject(&is_nil/1)
    |> Supervisor.start_link(opts)
  end

  defp cache_max_size do
    Application.get_env(:supabase, :storage)[:cache_max_size] || @default_cache_size
  end

  defp start_cache? do
    Application.get_env(:supabase, :storage)[:cache_buckets?]
  end

  defp reload_interval do
    Application.get_env(:supabase, :storage)[:reload_interval] || @default_buckets_reload_interval
  end
end
