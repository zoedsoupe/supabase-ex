defmodule Supabase.GoTrue.Plug.VerifyHeader do
  @moduledoc false

  import Plug.Conn

  alias Supabase.GoTrue

  @behaviour Plug

  @impl true
  def init(opts \\ []), do: opts

  @impl true
  def call(%Plug.Conn{} = conn, _opts) do
    if GoTrue.Plug.current_token(conn) do
      conn
    else
      case get_req_header(conn, :authorization) do
        ["Bearer " <> token] -> GoTrue.Plug.put_current_token(conn, token)
        _ -> halt(conn)
      end
    end
  end
end
