defmodule Supabase do
  @moduledoc """
  The main entrypoint for the Supabase SDK library.

  ## Installation

  The package can be installed by adding `supabase` to your list of dependencies in `mix.exs`:

      def deps do
        [
          {:supabase_potion, "~> 0.3"}
        ]
      end

  ## Usage

  After installing `:supabase_potion`, you can easily and dynamically manage different `Supabase.Client`!

  ### Config

  The library offers a bunch of config options that can be used to control management of clients and other options.

  - `manage_clients` - whether to manage clients automatically, defaults to `true`

  You can set up the library on your `config.exs`:

      config :supabase, manage_clients: false

  ### Clients

  A `Supabase.Client` is an Agent that holds general information about Supabase, that can be used to intereact with any of the children integrations, for example: `Supabase.Storage` or `Supabase.UI`.

  Also a `Supabase.Client` holds a list of `Supabase.Connection` that can be used to perform operations on different buckets, for example.

  `Supabase.Client` is defined as:

  - `:name` - the name of the client, started by `start_link/1`
  - `:conn` - connection information, the only required option as it is vital to the `Supabase.Client`.
    - `:base_url` - The base url of the Supabase API, it is usually in the form `https://<app-name>.supabase.io`.
    - `:api_key` - The API key used to authenticate requests to the Supabase API.
    - `:access_token` - Token with specific permissions to access the Supabase API, it is usually the same as the API key.
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


  ## Starting a Client

  You then can start a Client calling `Supabase.Client.start_link/1`:

      iex> Supabase.Client.start_link(name: :my_client, client_info: %{db: %{schema: "public"}})
      {:ok, #PID<0.123.0>}

  Notice that this way to start a Client is not recommended, since you will need to manage the `Supabase.Client` manually. Instead, you can use `Supabase.init_client!/1`, passing the Client options:

      iex> Supabase.Client.init_client!(%{conn: %{base_url: "<supa-url>", api_key: "<supa-key>"}})
      {:ok, #PID<0.123.0>}

  ## Acknowledgements

  This package represents the complete SDK for Supabase. That means
  that it includes all of the functionality of the Supabase client integrations, as:

  - `Supabase.Fetcher`
  - `Supabase.Storage`
  - `supabase-postgrest` - TODO
  - `supabase-realtime` - TODO
  - `supabase-auth`- TODO
  - `supabase-ui` - TODO

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

  alias Supabase.Client
  alias Supabase.ClientRegistry
  alias Supabase.ClientSupervisor

  alias Supabase.MissingSupabaseConfig

  @typep changeset :: Ecto.Changeset.t()

  @spec init_client(name :: atom, params) :: {:ok, pid} | {:error, changeset}
        when params: Client.params()
  def init_client(name, opts \\ %{}) do
    conn = Map.get(opts, :conn, %{})
    opts = maybe_merge_config_from_application(conn, opts)

    with {:ok, opts} <- Client.parse(Map.put(opts, :name, name)) do
      name = ClientRegistry.named(opts.name)
      client_opts = [name: name, client_info: opts]
      ClientSupervisor.start_child({Client, client_opts})
    end
  rescue
    _ -> Client.parse(opts)
  end

  def init_client!(name, %{} = opts \\ %{}) do
    conn = Map.get(opts, :conn, %{})
    opts = maybe_merge_config_from_application(conn, opts)

    case init_client(name, opts) do
      {:ok, pid} -> pid
      {:error, changeset} -> raise Ecto.InvalidChangesetError, changeset: changeset, action: :init
    end
  end

  defp maybe_merge_config_from_application(%{base_url: _, api_key: _}, opts), do: opts

  defp maybe_merge_config_from_application(%{}, opts) do
    base_url =
      Application.get_env(:supabase_potion, :supabase_base_url) ||
        raise MissingSupabaseConfig, :url

    api_key =
      Application.get_env(:supabase_potion, :supabase_api_key) ||
        raise MissingSupabaseConfig, :key

    Map.put(opts, :conn, %{base_url: base_url, api_key: api_key})
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @opaque changeset :: Ecto.Changeset.t()

      @callback changeset(__MODULE__.t(), map) :: changeset
      @callback parse(map) :: {:ok, __MODULE__.t()} | {:error, changeset}

      @optional_callbacks changeset: 2, parse: 1
    end
  end
end
