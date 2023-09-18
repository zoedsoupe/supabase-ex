defmodule Supabase.Storage.Application do
  @moduledoc "Entrypoint for the Apllication, defines the Supervision tree"

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if start_cache?() do
        [
          {Supabase.Storage.Cache, cache_max_size: cache_max_size()},
          {Supabase.Storage.CacheReloader, reload_interval: reload_interval()}
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: Supabase.Storage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cache_max_size do
    Application.get_env(:supabase_storage, :cache_max_size, 100)
  end

  defp start_cache? do
    Application.get_env(:supabase_storage, :cache_buckets?)
  end

  defp reload_interval do
    Application.get_env(:supabase_storage, :reload_interval)
  end
end
