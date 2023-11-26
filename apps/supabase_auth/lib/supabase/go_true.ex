defmodule Supabase.GoTrue do
  @moduledoc false

  import Supabase.Client, only: [is_client: 1]

  alias Supabase.Client
  alias Supabase.GoTrue.Schemas.SignInWithIdToken
  alias Supabase.GoTrue.Schemas.SignInWithOauth
  alias Supabase.GoTrue.Schemas.SignInWithPassword
  alias Supabase.GoTrue.Schemas.SignUpWithPassword
  alias Supabase.GoTrue.Session
  alias Supabase.GoTrue.User
  alias Supabase.GoTrue.UserHandler

  @opaque client :: pid | module

  @behaviour Supabase.GoTrueBehaviour

  @impl true
  def get_user(client, %Session{} = session) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, response} <- UserHandler.get_user(client, session.access_token) do
      User.parse(response)
    end
  end

  def sign_in_with_id_token(client, credentials) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, credentials} <- SignInWithIdToken.parse(credentials),
         {:ok, response} <- UserHandler.sign_in_with_id_token(client, credentials) do
      {:ok, response}
    end
  end

  @impl true
  def sign_in_with_oauth(client, credentials) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, credentials} <- SignInWithOauth.parse(credentials) do
      url = UserHandler.get_url_for_provider(client, credentials)
      {:ok, credentials.provider, url}
    end
  end

  @impl true
  def sign_in_with_password(client, credentials) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, credentials} <- SignInWithPassword.parse(credentials),
         {:ok, response} <- UserHandler.sign_in_with_password(client, credentials) do
      Session.parse(response)
    end
  end

  @impl true
  def sign_up(client, credentials) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, credentials} <- SignUpWithPassword.parse(credentials) do
      UserHandler.sign_up(client, credentials)
    end
  end
end
