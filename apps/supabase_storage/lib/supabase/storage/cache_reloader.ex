defmodule Supabase.Storage.CacheReloader do
  @moduledoc false

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
