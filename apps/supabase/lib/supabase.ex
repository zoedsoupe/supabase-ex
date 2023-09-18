defmodule Supabase do
  @moduledoc false

  alias Supabase.Client
  alias Supabase.ClientOptions
  alias Supabase.ClientSupervisor
  alias Supabase.Connection
  alias Supabase.ConnectionOptions
  alias Supabase.ConnectionSupervisor

  @typep changeset :: Ecto.Changeset.t()

  @spec init_client(params, list(Connection.t())) ::
          {:ok, pid} | {:error, changeset} | {:error, {atom, changeset}}
        when params: ClientOptions.t()
  def init_client(%{} = opts, connections) do
    with {:ok, opts} <- ClientOptions.parse(opts),
         client_opts = ClientOptions.to_client_info(opts, connections),
         {:ok, pid} <- ClientSupervisor.start_child({Client, client_opts}) do
      {:ok, Client.retrieve_client(pid)}
    end
  end

  @spec init_connection(params) ::
          {:ok, %{pid: pid, name: atom, alias: atom | String.t()}} | {:error, changeset}
        when params: ConnectionOptions.t()
  def init_connection(%{} = opts) do
    with {:ok, opts} <- ConnectionOptions.parse(opts),
         conn_params = ConnectionOptions.to_connection_info(opts),
         {:ok, pid} <- ConnectionSupervisor.start_child({Connection, conn_params}) do
      {:ok, Connection.retrieve_connection(pid)}
    end
  end
end
