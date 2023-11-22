defmodule Supabase.PostgREST.EctoAdapter do
  @moduledoc false

  alias Supabase.PostgREST.EctoAdapter.Connection

  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Queryable

  @impl Ecto.Adapter
  defmacro __before_compile__(_), do: []

  @impl Ecto.Adapter
  def checkout(_meta, _config, fun) do
    fun.()
  end

  @impl Ecto.Adapter
  def checked_out?(_meta), do: false

  @impl Ecto.Adapter
  def ensure_all_started(options, _type) do
    # IO.inspect(options, label: "ENSURE SYTARTED OPTS")
    Application.ensure_all_started(:supabase_potion)
    Application.ensure_all_started(:supabase_postgrest)
  end

  @impl Ecto.Adapter
  def init(opts \\ []) do
    {:ok, Connection.child_spec(opts), %{name: Connection, opts: opts}}
  end

  @impl Ecto.Adapter
  def dumpers(_, type), do: [type]

  @impl Ecto.Adapter
  def loaders(_, type), do: [type]

  @impl Ecto.Adapter.Schema
  def autogenerate(:id), do: nil
  def autogenerate(:binary_id), do: Ecto.UUID.generate()

  @impl Ecto.Adapter.Schema
  def insert(_adapter_meta, _schema_meta, attrs, _on_conflict, returning, _opts) do
    # IO.inspect(attrs, label: "CREATE ATTRS")
    # IO.inspect(returning, label: "CREATE RETURNING")
    {:ok, attrs}
  end

  @impl Ecto.Adapter.Schema
  def update(_adapter_meta, _schema_meta, attrs, filters, returning, _opts) do
    # IO.inspect(attrs, label: "UPDATE ATTRS")
    # IO.inspect(filters, label: "UPDATE FILTERS")
    # IO.inspect(returning, label: "UPDATE RETURNING")
    {:ok, attrs}
  end

  @impl Ecto.Adapter.Schema
  def delete(_adapter_meta, _schema_meta, filters, _opts) do
    # IO.inspect(filters, label: "DELETE FILTERS")
    {:ok, []}
  end

  @impl Ecto.Adapter.Queryable
  def prepare(_type, %Ecto.Query{} = query) do
    # req = PostgREST.Query.from_ecto_query(query)
    {:no_cache, query}
  end

  @impl Ecto.Adapter.Queryable
  def execute(_adapter_meta, query_meta, _query_cache, params, _opts) do
    # IO.inspect(query_meta, label: "QUERY META")
    # IO.inspect(params, label: "ExECUTE PARAMS")
    {1, nil}
  end

  @impl Ecto.Adapter.Queryable
  def stream(_adapter_meta, query_meta, _query_cache, params, _opts) do
    # IO.inspect(query_meta, label: "STREAM QUERY META")
    # IO.inspect(params, label: "STREAM PARAMS")
    Stream.repeatedly(fn -> {1, nil} end)
  end
end
