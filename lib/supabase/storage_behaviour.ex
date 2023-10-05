defmodule Supabase.StorageBehaviour do
  @moduledoc "Defines Supabase Storage Client callbacks"

  alias Supabase.Storage.Bucket
  alias Supabase.Storage.Object
  alias Supabase.Storage.ObjectOptions, as: Opts
  alias Supabase.Storage.SearchOptions, as: Search

  @type conn :: atom | pid
  @type reason :: String.t() | atom
  @type result(a) :: {:ok, a} | {:error, reason}

  @callback list_buckets(conn) :: result([Bucket.t()])
  @callback retrieve_bucket_info(conn, id) :: result(Bucket.t())
            when id: String.t()
  @callback create_bucket(conn, map) :: result(Bucket.t())
  @callback update_bucket(conn, Bucket.t(), map) :: result(Bucket.t())
  @callback empty_bucket(conn, Bucket.t()) :: result(:emptied)
  @callback delete_bucket(conn, Bucket.t()) :: result(:deleted)

  @callback remove_object(conn, Bucket.t(), Object.t()) :: result(:deleted)
  @callback move_object(conn, Bucket.t(), Object.t(), String.t()) :: result(:moved)
  @callback copy_object(conn, Bucket.t(), Object.t(), String.t()) :: result(:copied)
  @callback retrieve_object_info(conn, Bucket.t(), String.t()) :: result(Object.t())
  @callback list_objects(conn, Bucket.t(), prefix, Search.t()) :: result([Object.t()])
            when prefix: String.t()
  @callback upload_object(conn, Bucket.t(), dest, source, Opts.t()) :: result(Object.t())
            when dest: String.t(),
                 source: Path.t()
  @callback download_object(conn, Bucket.t(), wildcard) :: result(binary)
            when wildcard: String.t()
  @callback download_object_lazy(conn, Bucket.t(), wildcard) :: result(Stream.t())
            when wildcard: String.t()
  @callback save_object(conn, dest, Bucket.t(), wildcard) :: :ok | {:error, atom}
            when wildcard: String.t(),
                 dest: Path.t()
  @callback save_object_stream(conn, dest, Bucket.t(), wildcard) :: :ok | {:error, atom}
            when wildcard: String.t(),
                 dest: Path.t()
  @callback create_signed_url(conn, Bucket.t(), String.t(), integer) :: result(String.t())
end
