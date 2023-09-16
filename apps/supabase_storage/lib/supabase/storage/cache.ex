defmodule Supabase.Storage.Cache do
  @moduledoc false

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
