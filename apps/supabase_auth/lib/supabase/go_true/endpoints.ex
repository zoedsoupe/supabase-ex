defmodule Supabase.GoTrue.Endpoints do
  alias Supabase.Client

  @grant_types ~w[password]

  def sign_in(%Client{} = client, grant_type) when grant_type in @grant_types do
    query = URI.encode_query(%{grant_type: grant_type})
    Client.retrieve_auth_url(client, "/token?" <> query)
  end

  def sign_up(%Client{} = client) do
    Client.retrieve_auth_url(client, "/signup")
  end

  def user(%Client{} = client) do
    Client.retrieve_auth_url(client, "/user")
  end

  def sign_out(%Client{} = client, scope) do
    query = URI.encode_query(%{scope: scope})
    Client.retrieve_auth_url(client, "/logout?" <> query)
  end

  def invite(%Client{} = client) do
    Client.retrieve_auth_url(client, "/invite")
  end

  def generate_link(%Client{} = client) do
    Client.retrieve_auth_url(client, "/admin/generate_link")
  end

  def create_user(%Client{} = client) do
    Client.retrieve_auth_url(client, "/admin/users")
  end
end
