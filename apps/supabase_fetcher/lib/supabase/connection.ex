defmodule Supabase.Connection do
  @moduledoc """
  Defines the connection to Supabase, it is an Agent that holds the connection
  information and the current bucket.

  To start the connection you need to call `Supabase.Connection.start_link/1`:

      iex> Supabase.Connection.start_link(name: :my_conn, conn_info: %{base_url: "https://myapp.supabase.io", api_key: "my_api_key"})
      {:ok, #PID<0.123.0>}

  But usually you would add the connection to your supervision tree:

      defmodule MyApp.Application do
        use Application

        def start(_type, _args) do
          conn_info = %{base_url: "https://myapp.supabase.io", api_key: "my_api_key"}

          children = [
            {Supabase.Connection, conn_info: conn_info, name: :my_conn}
          ]

          opts = [strategy: :one_for_one, name: MyApp.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end

  Once the connection is started you can use it to perform operations on the
  storage service, for example to list all the buckets:

      iex> conn = Supabase.Connection.fetch_current_bucket!(:my_conn)
      iex> Supabase.Storage.list_buckets(conn)
      {:ok, [
        %Supabase.Storage.Bucket{
          allowed_mime_types: nil,
          file_size_limit: nil,
          id: "my-bucket-id",
          name: "my-bucket",
          public: true
        }
      ]}

  Notice that you can start multiple connections, each one with different
  credentials, and you can use them to perform operations on different buckets!
  """

  use Agent

  @type base_url :: String.t()
  @type api_key :: String.t()
  @type access_token :: String.t()
  @type bucket :: struct

  @fields ~w(base_url api_key access_token bucket)a

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    conn_info = Keyword.fetch!(args, :conn_info)

    Agent.start_link(fn -> parse_init_args(conn_info) end, name: name)
  end

  defp parse_init_args(conn_info) do
    conn_info
    |> Map.take(@fields)
    |> Map.put_new(:access_token, conn_info[:api_key])
  end

  def fetch_current_bucket!(conn) do
    Agent.get(conn, &Map.get(&1, :bucket)) ||
      raise "No current bucket configured on your connection"
  end

  def get_base_url(conn) do
    Agent.get(conn, &Map.get(&1, :base_url))
  end

  def get_api_key(conn) do
    Agent.get(conn, &Map.get(&1, :api_key))
  end

  def get_access_token(conn) do
    Agent.get(conn, &Map.get(&1, :access_token))
  end

  def put_access_token(conn, token) do
    Agent.update(conn, &Map.put(&1, :access_token, token))
  end

  def put_current_bucket(conn, bucket) do
    Agent.update(conn, &Map.put(&1, :bucket, bucket))
  end

  def remove_current_bucket(conn) do
    Agent.update(conn, &Map.delete(&1, :bucket))
  end
end
