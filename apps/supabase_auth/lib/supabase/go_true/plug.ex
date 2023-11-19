defmodule Supabase.GoTrue.Plug do
  @moduledoc false

  import Plug.Conn
  import Supabase.Client, only: [is_client: 1]

  alias Plug.Conn

  @key "supabase_gotrue_token"

  def session_active?(%Conn{} = conn) do
    key = :second |> System.os_time() |> to_string()
    get_session(conn, key) == nil
  rescue
    ArgumentError -> false
  end

  def authenticated?(%Conn{} = conn) do
    not is_nil(conn.private[@key])
  end

  def put_current_token(%Conn{} = conn, token) do
    put_private(conn, @key, token)
  end

  def put_session_token(%Conn{} = conn, token) do
    conn
    |> put_session(@key, token)
    |> configure_session(renew: true)
  end

  def sig_in(%Conn{} = conn, client, attrs) when is_client(client) do
    case maybe_sign_in(conn, client, attrs) do
      {:ok, session} -> put_session_token(conn, session.access_token)
      _ -> conn
    end
  end

  defp maybe_sign_in(conn, client, credentials) do
    if session_active?(conn) do
      Supabase.GoTrue.sign_in_with_password(client, credentials)
    end
  end

  def sign_out(%Conn{} = conn) do
    if session_active?(conn) do
      delete_session(conn, @key)
    else
      conn
    end
  end

  def fetch_token_from_cookies(%Conn{} = conn) do
    token = conn.req_cookies[@key] || conn.req_cookies[to_string(@key)]
    if token, do: {:ok, token}, else: {:error, :not_found}
  end

  def current_token(%Conn{} = conn) do
    conn.private[@key]
  end
end
