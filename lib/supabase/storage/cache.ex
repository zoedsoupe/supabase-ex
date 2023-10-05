defmodule Supabase.Storage.Cache do
  @moduledoc """
  Provides caching mechanisms for Supabase Storage Buckets.

  This module acts as a GenServer that offers caching capabilities, especially for bucket-related operations in Supabase Storage. The caching is backed by the `:ets` (Erlang Term Storage) to provide in-memory storage and fast retrieval of cached data.

  ## Features

  - **Bucket Caching**: Store and retrieve buckets by their unique identifier.
  - **Cache Flushing**: Clear the cache when necessary.
  - **Configurable Cache Size**: Limit the number of items that can be stored in the cache.

  ## Usage

  ### Starting the Cache Server

      Supabase.Storage.Cache.start_link(%{cache_max_size: 200})

  ### Caching Buckets

      buckets = [%{id: "bucket_1", ...}, %{id: "bucket_2", ...}]
      Supabase.Storage.Cache.cache_buckets(buckets)

  ### Retrieving a Cached Bucket by ID

      Supabase.Storage.Cache.find_bucket_by_id("bucket_1")

  ### Clearing the Cache

      Supabase.Storage.Cache.flush()

  ## Implementation Details

  The cache uses the `:ets` module for in-memory storage of buckets. The number of buckets cached is controlled by the `:cache_max_size` option (default: 100). When the cache is close to exceeding its maximum size, older entries are removed to accommodate new ones.
  """

  use GenServer

  ## Client

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def find_bucket_by_id(id) do
    GenServer.call(__MODULE__, {:find_bucket, id: id})
  end

  def cache_buckets(buckets) do
    GenServer.cast(__MODULE__, {:cache_buckets, buckets})
  end

  def flush do
    GenServer.cast(__MODULE__, :flush)
  end

  ## API

  @impl true
  def init(args) do
    Process.flag(:trap_exit, true)
    table = :ets.new(:buckets_cache, [:set, :public, :named_table])
    max_size = Keyword.get(args, :cache_max_size, 100)
    {:ok, %{table: table, max_size: max_size, size: 0}}
  end

  @impl true
  def handle_cast(:flush, table) do
    :ets.delete_all_objects(table)
    {:noreply, table}
  end

  def handle_cast({:cache_buckets, buckets}, state) do
    if overflowed_max_size?(state, buckets) do
      :ets.delete_all_objects(state.table)
    end

    # prefer atomic operations
    for bucket <- buckets do
      :ets.insert_new(state.table, {bucket.id, bucket})
    end

    {:noreply, %{state | size: length(buckets)}}
  end

  defp overflowed_max_size?(state, buckets) do
    state.size + length(buckets) > state.max_size
  end

  @impl true
  def handle_call({:find_bucket, id: id}, _from, state) do
    bucket = :ets.lookup_element(state.table, id, 2)
    {:reply, bucket, state}
  rescue
    _ -> {:reply, nil, state}
  end
end
