defmodule Supabase.Client do
  @moduledoc """
  A client for interacting with Supabase. This module is responsible for
  managing the connection options for your Supabase project.

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
