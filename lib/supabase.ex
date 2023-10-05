defmodule Supabase do
  @moduledoc """
  The main entrypoint for the Supabase SDK library.

  ## Installation

  The package can be installed by adding `supabase` to your list of dependencies in `mix.exs`:

      def deps do
        [
          {:supabase_potion, "~> 0.1"}
        ]
      end

  ## Usage

  After installing `:supabase_potion`, you can easily and dynamically manage different `Supabase.Client` and their `Supabase.Connection`. That means you can have multiple Supabase clients that manage multiple Supabase connections.

  ### Clients vs Connections

  A `Supabase.Client` is an Agent that holds general information about Supabase, that can be used to intereact with any of the children integrations, for example: `Supabase.Storage` or `Supabase.UI`.

  Also a `Supabase.Client` holds a list of `Supabase.Connection` that can be used to perform operations on different buckets, for example.

  `Supabase.Client` is defined as:

  - `:name` - the name of the client, started by `start_link/1`
  - `:connections` - a list of `%{conn_alias => conn_name}`, where `conn_alias` is the alias of the connection and `conn_name` is the name of the connection.
  - `:db` - default database options
    - `:schema` - default schema to use, defaults to `"public"`
  - `:global` - global options config
    - `:headers` - additional headers to use on each request
  - `:auth` - authentication options
    - `:auto_refresh_token` - automatically refresh the token when it expires, defaults to `true`
    - `:debug` - enable debug mode, defaults to `false`
    - `:detect_session_in_url` - detect session in URL, defaults to `true`
    - `:flow_type` - authentication flow type, defaults to `"web"`
    - `:persist_session` - persist session, defaults to `true`
    - `:storage` - storage type
    - `:storage_key` - storage key


  On the other side, a `Supabase.Connection` is an Agent that holds the connection information and the current bucket, being defined as:

  - `:base_url` - The base url of the Supabase API, it is usually in the form `https://<app-name>.supabase.io`.
  - `:api_key` - The API key used to authenticate requests to the Supabase API.
  - `:access_token` - Token with specific permissions to access the Supabase API, it is usually the same as the API key.
  - `:name` - Simple field to track the name of the connection, started by `start_link/1`.
  - `:alias` - Field to easily manage multiple connections on a `Supabase.Client` Agent.
  - `:bucket` - The current bucket to perform operations on.

  In simple words, a `Supabase.Client` is a container for multiple `Supabase.Connection`, and each `Supabase.Connection` is a container for a single bucket.

  ## Starting a Connection

  To start a new Connection you need to call `Supabase.Connection.start_link/1`:

       iex> Supabase.Connection.start_link(name: :my_conn, conn_info: %{base_url: "https://myapp.supabase.io", api_key: "my_api_key"})
       {:ok, #PID<0.123.0>}

  But usually you would start a Connection using a higher level API, defined in `Supabase` module, using the `Supabase.init_connection/1` function:

       iex> Supabase.init_connection(%{base_url: "https://myapp.supabase.io", api_key: "my_api_key", name: :my_conn, alias: :conn1})
       {:ok, #PID<0.123.0>}

  ## Starting a Client

  After starting some Connections, you then can start a Client calling `Supabase.Client.start_link/1`:

      iex> Supabase.Client.start_link(name: :my_client, client_info: %{db: %{schema: "public"}})
      {:ok, #PID<0.123.0>}

  Notice that this way to start a Client is not recommended, since you will need to manage the `Supabase.Client` manually. Instead, you can use `Supabase.init_client/2`, passing the Client options, and also a list of connections that the Client will manage:

      iex> Supabase.Client.init_client(%{db: %{schema: "public"}}, conn_list)
      {:ok, #PID<0.123.0>}

  ## Acknowledgements

  This package represents the complete SDK for Supabase. That means
  that it includes all of the functionality of the Supabase client integrations, as:

  - `supabase-storage` - [Hex documentation](https://hex.pm/packages/supabase_storage)
  - `supabase-postgrest` - [Hex documentation](https://hex.pm/packages/supabase_postgrest)
  - `supabase-realtime` - [Hex documentation](https://hex.pm/packages/supabase_realtime)
  - `supabase-auth` - [Hex documentation](https://hex.pm/packages/supabase_auth)
  - `supabase-ui` - [Hex documentation](https://hex.pm/packages/supabase_ui)
  - `supabase-fetcher` - [Hex documentation](https://hex.pm/packages/supabase_fetcher)

  Of course, if you would like to use only a specific functionality, you can use the following a desired number of packages, example:

      defp deps do
        [
          {:supabase_storage, "~> 0.1"},
          {:supabase_realtime, "~> 0.1"},
        ]
      end

  Notice that if you prefer to install only a specific package, you will need to manage a `Supabase.Connection` manually. More documentation can be found in [supabase_connection documentation](https://hexdocs.pm/supabase_connection).

  ### Supabase Storage

  Supabase Storage is a service for developers to store large objects like images, videos, and other files. It is a hosted object storage service, like AWS S3, but with a simple API and strong consistency.

  ### Supabase PostgREST

  PostgREST is a web server that turns your PostgreSQL database directly into a RESTful API. The structural constraints and permissions in the database determine the API endpoints and operations.

  ### Supabase Realtime

  Supabase Realtime provides a realtime websocket API powered by PostgreSQL notifications. It allows you to listen to changes in your database, and instantly receive updates as soon as they happen.

  ### Supabase Auth

  Supabase Auth is a feature-complete user authentication system. It provides email & password sign in, email verification, password recovery, session management, and more, out of the box.

  ### Supabase UI

  Supabase UI is a set of UI components that help you quickly build Supabase-powered applications. It is built on top of Tailwind CSS and Headless UI, and is fully customizable. The package provides `Phoenix.LiveView` components!

  ### Supabase Fetcher

  Supabase Fetcher is a customized HTTP client for Supabase. Mainly used in Supabase Potion. If you want a complete control on how to make requests to any Supabase API, you would use this package directly.
  """

  alias Supabase.ClientRegistry
  alias Supabase.Client
  alias Supabase.ClientSupervisor

  @typep changeset :: Ecto.Changeset.t()

  @spec init_client(params) :: {:ok, pid} | {:error, changeset}
        when params: Client.params()
  def init_client(%{} = opts) do
    with {:ok, opts} <- Client.parse(opts) do
      name = ClientRegistry.named(opts.name)
      client_opts = [name: name, client_info: opts]
      ClientSupervisor.start_child({Client, client_opts})
    end
  end
end
