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

  ## Fields

  Currently the connection holds the following fields:

  - `:base_url` - The base url of the Supabase API, it is usually in the form
    `https://<app-name>.supabase.io`.
  - `:api_key` - The API key used to authenticate requests to the Supabase API.
  - `:access_token` - Token with specific permissions to access the Supabase API, it is usually the same as the API key.
  - `name`: Simple field to track the name of the connection, started by `start_link/1`.
  - `alias`: Field to easily manage multiple connections on a `Supabase.Client` Agent.
  """

  use Agent
  use Ecto.Schema

  alias Supabase.MissingSupabaseConfig

  @type t :: %__MODULE__{
          base_url: base_url,
          api_key: api_key,
          access_token: access_token,
          bucket: bucket
        }

  @type params :: [
          name: atom,
          conn_info: %{
            base_url: base_url,
            api_key: api_key,
            access_token: access_token,
            bucket: bucket
          }
        ]

  @type base_url :: String.t()
  @type api_key :: String.t()
  @type access_token :: String.t()
  @type bucket :: struct

  @primary_key false
  embedded_schema do
    field(:alias, Supabase.Types.Atom)
    field(:name, Supabase.Types.Atom)
    field(:base_url, :string)
    field(:api_key, :string)
    field(:access_token, :string)
    field(:bucket, :map)
  end

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    conn_info = Keyword.fetch!(args, :conn_info)

    Agent.start_link(fn -> parse_init_args!(conn_info) end, name: name)
  end

  defp parse_init_args!(conn_info) do
    base_url = Map.get(conn_info, :base_url) || raise MissingSupabaseConfig, :url
    api_key = Map.get(conn_info, :api_key) || raise MissingSupabaseConfig, :key
    access_token = Map.get(conn_info, :access_token, api_key)
    bucket = Map.get(conn_info, :bucket)
    alias = Map.get(conn_info, :alias)
    name = Map.get(conn_info, :name)

    %__MODULE__{
      alias: alias,
      name: name,
      base_url: base_url,
      api_key: api_key,
      access_token: access_token,
      bucket: bucket
    }
  end

  def fetch_current_bucket!(conn) do
    Agent.get(conn, &Map.get(&1, :bucket)) ||
      raise "No current bucket configured on connection #{inspect(conn)}"
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

  def retrieve_connection(name) do
    Agent.get(name, & &1)
  end
end
