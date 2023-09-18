defmodule Supabase.ClientOptions do
  @moduledoc false

  import Ecto.Changeset

  alias Supabase.Types.Atom

  @type t :: %{
          client_name: atom,
          db: %{
            schema: String.t()
          },
          global: %{
            headers: Map.t()
          },
          auth: %{
            auto_refresh_token: boolean(),
            debug: boolean(),
            detect_session_in_url: boolean(),
            flow_type: String.t(),
            persist_session: boolean(),
            storage: String.t(),
            storage_key: String.t()
          }
        }

  @base_types %{
    db: :map,
    global: :map,
    auth: :map,
    client_name: Ecto.ParameterizedType.init(Atom, [])
  }

  @db_types %{schema: :string}
  @global_types %{headers: :map}

  @auth_types %{
    auto_refresh_token: :boolean,
    debug: :boolean,
    detect_session_in_url: :boolean,
    flow_type: :string,
    persist_session: :boolean,
    storage: :string,
    storage_key: :string
  }

  @spec parse(map) ::
          {:ok, Supabase.ClientOptions.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, {atom, Ecto.Changeset.t()}}
  def parse(attrs) do
    with {:ok, db} <- cast_db(attrs[:db] || %{}),
         {:ok, global} <- cast_global(attrs[:global] || %{}),
         {:ok, auth} <- cast_auth(attrs[:auth] || %{}) do
      {%{}, @base_types}
      |> cast(attrs, Map.keys(@base_types))
      |> validate_required(~w[client_name]a)
      |> put_change(:db, db)
      |> put_change(:global, global)
      |> put_change(:auth, auth)
      |> apply_action(:parse)
    end
  end

  @spec cast_db(map) :: {:ok, map} | {:error, {:db, Ecto.Changeset.t()}}
  defp cast_db(attrs) do
    {%{}, @db_types}
    |> cast(attrs, Map.keys(@db_types))
    |> maybe_put_default_schema()
    |> apply_action(:parse_db)
    |> case do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, {:db, changeset}}
    end
  end

  defp maybe_put_default_schema(changeset) do
    if get_change(changeset, :schema) do
      changeset
    else
      put_change(changeset, :schema, "public")
    end
  end

  @spec cast_global(map) :: {:ok, map} | {:error, {:global, Ecto.Changeset.t()}}
  defp cast_global(attrs) do
    {%{}, @global_types}
    |> cast(attrs, Map.keys(@global_types))
    |> apply_action(:parse_global)
    |> case do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, {:global, changeset}}
    end
  end

  @spec cast_auth(map) :: {:ok, map} | {:error, {:auth, Ecto.Changeset.t()}}
  defp cast_auth(attrs) do
    {%{}, @auth_types}
    |> cast(attrs, Map.keys(@auth_types))
    |> maybe_put_default_flow_type()
    |> maybe_persist_session()
    |> maybe_debug()
    |> maybe_auto_refresh_token()
    |> maybe_detect_session_in_url()
    |> apply_action(:parse_auth)
    |> case do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, {:auth, changeset}}
    end
  end

  defp maybe_put_default_flow_type(changeset) do
    if get_change(changeset, :flow_type) do
      changeset
    else
      put_change(changeset, :flow_type, "magicLink")
    end
  end

  defp maybe_persist_session(changeset) do
    if get_change(changeset, :persist_session) do
      changeset
    else
      put_change(changeset, :persist_session, true)
    end
  end

  defp maybe_debug(changeset) do
    if get_change(changeset, :debug) do
      changeset
    else
      put_change(changeset, :debug, false)
    end
  end

  defp maybe_auto_refresh_token(changeset) do
    if get_change(changeset, :auto_refresh_token) do
      changeset
    else
      put_change(changeset, :auto_refresh_token, true)
    end
  end

  defp maybe_detect_session_in_url(changeset) do
    if get_change(changeset, :detect_session_in_url) do
      changeset
    else
      put_change(changeset, :detect_session_in_url, true)
    end
  end

  @spec to_client_info(t, list(Supabase.Connection.t())) :: Supabase.Client.params()
  def to_client_info(data, conns) do
    connections = Enum.map(conns, &Map.new([{&1.alias, &1.name}]))

    client_info =
      data
      |> Map.take(~w[db global auth]a)
      |> Map.put(:connections, connections)
      |> Map.put(:name, data[:client_name])

    [
      name: data[:client_name],
      client_info: client_info
    ]
  end
end
