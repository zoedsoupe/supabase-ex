defmodule Supabase do
  @moduledoc """
  The main entrypoint for the Supabase SDK library.

  ## Installation

  The package can be installed by adding `supabase_potion` to your list of dependencies in `mix.exs`:

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

  A `Supabase.Client`  holds general information about Supabase, that can be used to intereact with any of the children integrations, for example: `Supabase.Storage` or `Supabase.UI`.

  `Supabase.Client` is defined as:

  - `:conn` - connection information, the only required option as it is vital to the `Supabase.Client`.
    - `:base_url` - The base url of the Supabase API, it is usually in the form `https://<app-name>.supabase.co`.
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

  You then can start a Client calling `Supabase.init_client/1`:

      iex> Supabase.init_client(%{db: %{schema: "public"}})
      {:ok, %Supabase.Client{}}

  ## Acknowledgements

  This package represents the base SDK for Supabase. That means
  that it not includes all of the functionality of the Supabase client integrations, so you need to install each feature separetely, as:

  - [auth](https://github.com/zoedsoupe/gotrue-ex)
  - [storage](https://github.com/zoedsoupe/storage-ex)
  - [postgrest](https://github.com/zoedsoupe/postgrest-ex)
  - `realtime` - TODO
  - `ui` - TODO

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
  """

  alias Supabase.Client

  alias Supabase.MissingSupabaseConfig

  @typep changeset :: Ecto.Changeset.t()

  @spec init_client(Client.params() | %{}) :: {:ok, Client.t()} | {:error, changeset}
  def init_client(opts \\ %{}) do
    opts
    |> Map.get(:conn, %{})
    |> maybe_merge_config_from_application(opts)
    |> Client.parse()
  end

  def init_client!(%{} = opts \\ %{}) do
    conn = Map.get(opts, :conn, %{})
    opts = maybe_merge_config_from_application(conn, opts)

    case init_client(opts) do
      {:ok, client} ->
        client

      {:error, changeset} ->
        errors = errors_on_changeset(changeset)

        if "can't be blank" in get_in(errors, [:conn, :api_key]) do
          raise MissingSupabaseConfig, :key
        end

        if "can't be blank" in get_in(errors, [:conn, :base_url]) do
          raise MissingSupabaseConfig, :url
        end

        raise Ecto.InvalidChangesetError, changeset: changeset, action: :init
    end
  end

  defp maybe_merge_config_from_application(%{base_url: _, api_key: _}, opts), do: opts

  defp maybe_merge_config_from_application(%{}, opts) do
    base_url = Application.get_env(:supabase_potion, :supabase_base_url)
    api_key = Application.get_env(:supabase_potion, :supabase_api_key)

    Map.put(opts, :conn, %{base_url: base_url, api_key: api_key})
  end

  defp errors_on_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
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
