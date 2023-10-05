defmodule Supabase.Storage.CacheReloader do
  @moduledoc """
  Periodically reloads and updates the bucket cache for Supabase Storage.

  This module acts as a GenServer that schedules periodic tasks to reload and update the cache for Supabase Storage Buckets. It collaborates with the `Supabase.Storage.Cache` to ensure that the cached data remains fresh and updated.

  ## Features

  - **Automatic Cache Reloading**: Periodically reloads the buckets from Supabase Storage and updates the cache.
  - **Configurable Reload Interval**: The time interval between successive cache reloads can be specified.

  ## Usage

  ### Starting the CacheReloader Server

      Supabase.Storage.CacheReloader.start_link(%{reload_interval: 2_000})

  ## Implementation Details

  By default, the reload interval is set to 1 second (`@ttl`). This means the cache will be updated every second with the latest data from Supabase Storage. This interval can be configured during the server start using the `:reload_interval` option.

  The server interacts with `Supabase.Storage.list_buckets/1` to fetch the list of buckets and then updates the cache using `Supabase.Storage.Cache.cache_buckets/1`.
  """

  use GenServer

  alias Supabase.Storage.Cache

  # @ttl 60_000
  @ttl 1_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    Process.flag(:trap_exit, true)
    interval = Keyword.get(args, :reload_interval, @ttl)
    Process.send_after(self(), :reload, interval)
    {:ok, interval}
  end

  @impl true
  def handle_info(:reload, interval) do
    {:ok, buckets} = Supabase.Storage.list_buckets(Supabase.Connection)
    :ok = Cache.cache_buckets(buckets)
    Process.send_after(self(), :reload, interval)
    {:noreply, interval}
  end
end
