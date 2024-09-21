defmodule Supabase.Client do
  @moduledoc """
  A client for interacting with Supabase. This module is responsible for
  managing the connection options for your Supabase project.

  ## Usage

  Generally, you can start a client by calling `Supabase.init_client/3`:

      iex> base_url = "https://<app-name>.supabase.io"
      iex> api_key = "<supabase-api-key>"
      iex> Supabase.init_client(base_url, api_key, %{})
      {:ok, %Supabase.Client{}}

  > That way of initialisation is useful when you want to manage the connection options yourself or create one off clients.

  However, starting a client directly means you have to manage the connection options yourself. To make it easier, you can use the `Supabase.Client` module to manage the connection options for you.

  To achieve this you can use the `Supabase.Client` module in your module:

      defmodule MyApp.Supabase.Client do
        use Supabase.Client
      end

  This will automatically start an Agent process to manage the connection options for you. But for that to work, you need to configure your defined Supabase client in your `config.exs`:

      config :supabase_potion, MyApp.Supabase.Client,
        base_url: "https://<app-name>.supabase.co",
        api_key: "<supabase-api-key>",
        conn: %{access_token: "<supabase-access-token>"}, # optional
        db: %{schema: "another"}, # default to public
        auth: %{debug: true} # optional

  Another alternative would be to configure your Supabase Client at runtime, while starting your application:

      defmodule MyApp.Application do
        use Application

        def start(_type, _args) do
          children = [
            {MyApp.Supabase.Client, [
              base_url: "https://<app-name>.supabase.co",
              api_key: "<supabase-api-key>"
            ]}
          ]

          opts = [strategy: :one_for_one, name: MyApp.Supabase.Client.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end

  For more information on how to configure your Supabase Client with additional options, please refer to the [Supabase official documentation](https://supabase.com/docs/reference/javascript/initializing)

  ## Examples

      %Supabase.Client{
        conn: %{
          base_url: "https://<app-name>.supabase.io",
          api_key: "<supabase-api-key>",
          access_token: "<supabase-access-token>"
        },
        db: %Supabase.Client.Db{
          schema: "public"
        },
        global: %Supabase.Client.Global{
          headers: %{}
        },
        auth: %Supabase.Client.Auth{
          auto_refresh_token: true,
          debug: false,
          detect_session_in_url: true,
          flow_type: :implicit,
          persist_session: true,
          storage: nil,
          storage_key: "sb-<host>-auth-token"
        }
      }

      iex> Supabase.Client.retrieve_connection(%Supabase.Client{})
      %Supabase.Client.Conn{
        base_url: "https://<app-name>.supabase.io",
        api_key: "<supabase-api-key>",
        access_token: "<supabase-access-token>"
      }
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Supabase.Client.Auth
  alias Supabase.Client.Conn
  alias Supabase.Client.Db
  alias Supabase.Client.Global

  @type t :: %__MODULE__{
          conn: Conn.t(),
          db: Db.t(),
          global: Global.t(),
          auth: Auth.t()
        }

  @type params :: %{
          conn: Conn.params(),
          db: Db.params(),
          global: Global.params(),
          auth: Auth.params()
        }

  defmacro __using__(_) do
    quote do
      use Agent

      import Supabase.Client, only: [
        update_access_token: 2,
        retrieve_connection: 1,
        retrieve_base_url: 1,
        retrieve_auth_url: 2,
        retrieve_storage_url: 2
      ]

      alias Supabase.MissingSupabaseConfig

      @doc """
      Start an Agent process to manage the Supabase client instance.

      ## Usage

      First, define your client module and use the `Supabase.Client` module:

          defmodule MyApp.Supabase.Client do
            use Supabase.Client
          end

      Note that you need to configure it with your Supabase project details. You can do this by setting the `base_url` and `api_key` in your `config.exs` file:

          config :supabase_potion, MyApp.Supabase.Client,
            base_url: "https://<app-name>.supabase.co",
            api_key: "<supabase-api-key>",
            conn: %{access_token: "<supabase-access-token>"}, # optional
            db: %{schema: "another"}, # default to public
            auth: %{debug: true} # optional

      Then, on your `application.ex` file, you can start the agent process by adding your defined client into the Supervision tree of your project:

          def start(_type, _args) do
            children = [
              MyApp.Supabase.Client
            ]

            Supervisor.init(children, strategy: :one_for_one)
          end

      For alternatives on how to start and define your Supabase client instance, please refer to the [Supabase.Client module documentation](https://hexdocs.pm/supabase_potion/Supabase.Client.html).

      For more information on how to start an Agent process, please refer to the [Agent module documentation](https://hexdocs.pm/elixir/Agent.html).
      """
      def start_link(opts \\ [])

      def start_link(opts) when is_list(opts) and opts == [] do
        config = Application.get_env(:supabase_potion, __MODULE__)

        if is_nil(config) do
          raise MissingSupabaseConfig, key: :config, client: __MODULE__
        end

        base_url = Keyword.get(config, :base_url)
        api_key = Keyword.get(config, :api_key)
        name = Keyword.get(config, :name, __MODULE__)
        params = Map.new(config)

        if is_nil(base_url) do
          raise MissingSupabaseConfig, key: :url, client: __MODULE__
        end

        if is_nil(api_key) do
          raise MissingSupabaseConfig, key: :key, client: __MODULE__
        end

        Agent.start_link(fn -> Supabase.init_client!(base_url, api_key, params) end, name: name)
      end

      def start_link(opts) when is_list(opts) do
        base_url = Keyword.get(opts, :base_url)
        api_key = Keyword.get(opts, :api_key)

        if is_nil(base_url) do
          raise MissingSupabaseConfig, key: :url, client: __MODULE__
        end

        if is_nil(api_key) do
          raise MissingSupabaseConfig, key: :key, client: __MODULE__
        end

        name = Keyword.get(opts, :name, __MODULE__)
        params = Map.new(opts)

        Agent.start_link(fn ->
          Supabase.init_client!(base_url, api_key, params)
        end, name: name)
      end

      @doc """
      Retrieve the client instance from the Agent process, so you can use it to interact with the Supabase API.
      """
      @spec get_client(pid | atom) :: {:ok, Supabase.Client.t} | {:error, :not_found}
      def get_client(pid \\ __MODULE__) do
        case Agent.get(pid, & &1) do
          nil -> {:error, :not_found}
          client -> {:ok, client}
        end
      end
    end
  end

  @primary_key false
  embedded_schema do
    embeds_one(:conn, Conn)
    embeds_one(:db, Db)
    embeds_one(:global, Global)
    embeds_one(:auth, Auth)
  end

  @spec parse(params) :: {:ok, t} | {:error, Ecto.Changeset.t()}
  def parse(attrs) do
    %__MODULE__{}
    |> cast(attrs, [])
    |> cast_embed(:conn, required: true)
    |> cast_embed(:db, required: false)
    |> cast_embed(:global, required: false)
    |> cast_embed(:auth, required: false)
    |> maybe_put_assocs()
    |> validate_required([:conn])
    |> apply_action(:parse)
  end

  @spec parse!(params) :: Supabase.Client.t()
  def parse!(attrs) do
    case parse(attrs) do
      {:ok, changeset} ->
        changeset

      {:error, changeset} ->
        raise Ecto.InvalidChangesetError, changeset: changeset, action: :parse
    end
  end

  defp maybe_put_assocs(%{valid?: false} = changeset), do: changeset

  defp maybe_put_assocs(changeset) do
    auth = get_change(changeset, :auth)
    db = get_change(changeset, :db)
    global = get_change(changeset, :global)

    changeset
    |> maybe_put_assoc(:auth, auth, %Auth{})
    |> maybe_put_assoc(:db, db, %Db{})
    |> maybe_put_assoc(:global, global, %Global{})
  end

  defp maybe_put_assoc(changeset, key, nil, default),
    do: put_change(changeset, key, default)

  defp maybe_put_assoc(changeset, _key, _assoc, _default), do: changeset

  @spec update_access_token(t, String.t()) :: t
  def update_access_token(%__MODULE__{} = client, access_token) do
    path = [Access.key(:conn), Access.key(:access_token)]
    put_in(client, path, access_token)
  end

  @doc """
  Given a `Supabase.Client`, return the connection informations.

  ## Examples

      iex> Supabase.Client.retrieve_connection(%Supabase.Client{})
      %Supabase.Client.Conn{}
  """
  @spec retrieve_connection(t) :: Conn.t()
  def retrieve_connection(%__MODULE__{conn: conn}), do: conn

  @doc """
  Given a `Supabase.Client`, return the raw the base url for the Supabase project.

  ## Examples

      iex> Supabase.Client.retrieve_base_url(%Supabase.Client{})
      "https://<app-name>.supabase.co"
  """
  @spec retrieve_base_url(t) :: String.t()
  def retrieve_base_url(%__MODULE__{conn: conn}) do
    conn.base_url
  end

  @spec retrieve_url(t, String.t()) :: URI.t()
  defp retrieve_url(%__MODULE__{} = client, uri) do
    client
    |> retrieve_base_url()
    |> URI.merge(uri)
  end

  @doc """
  Given a `Supabase.Client`, mounts the base url for the Auth/GoTrue feature.

  ## Examples

      iex> Supabase.Client.retrieve_auth_url(%Supabase.Client{})
      "https://<app-name>.supabase.co/auth/v1"
  """
  @spec retrieve_auth_url(t, String.t()) :: String.t()
  def retrieve_auth_url(%__MODULE__{auth: auth} = client, uri \\ "/") do
    client
    |> retrieve_url(auth.uri)
    |> URI.append_path(uri)
    |> URI.to_string()
  end

  @storage_endpoint "/storage/v1"

  @doc """
  Given a `Supabase.Client`, mounts the base url for the Storage feature.

  ## Examples

      iex> Supabase.Client.retrieve_storage_url(%Supabase.Client{})
      "https://<app-name>.supabase.co/storage/v1"
  """
  @spec retrieve_storage_url(t, String.t()) :: String.t()
  def retrieve_storage_url(%__MODULE__{} = client, uri \\ "/") do
    client
    |> retrieve_url(@storage_endpoint)
    |> URI.append_path(uri)
    |> URI.to_string()
  end

  defimpl Inspect, for: Supabase.Client do
    import Inspect.Algebra

    def inspect(%Supabase.Client{} = client, opts) do
      concat([
        "#Supabase.Client<",
        nest(
          concat([
            line(),
            "base_url: ",
            to_doc(client.conn.base_url, opts),
            ",",
            line(),
            "schema: ",
            to_doc(client.db.schema, opts),
            ",",
            line(),
            "auth: (",
            "flow_type: ",
            to_doc(client.auth.flow_type, opts),
            ", ",
            "persist_session: ",
            to_doc(client.auth.persist_session, opts),
            ")"
          ]),
          2
        ),
        line(),
        ">"
      ])
    end
  end
end
