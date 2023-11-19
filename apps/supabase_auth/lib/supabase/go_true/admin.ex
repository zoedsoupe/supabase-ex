defmodule Supabase.GoTrue.Admin do
  @moduledoc false

  import Supabase.Client, only: [is_client: 1]

  alias Supabase.Client
  alias Supabase.Fetcher
  alias Supabase.GoTrue.Endpoints
  alias Supabase.GoTrue.User
  alias Supabase.GoTrue.Schemas.AdminUserParams
  alias Supabase.GoTrue.Schemas.GenerateLink
  alias Supabase.GoTrue.Schemas.InviteUserParams
  alias Supabase.GoTrue.Session

  @behaviour Supabase.GoTrue.AdminBehaviour

  @scopes ~w[global local others]a

  @impl true
  def sign_out(client, %Session{} = session, scope) when is_client(client) and scope in @scopes do
    with {:ok, client} <- Client.retrieve_client(client) do
      headers = Fetcher.apply_client_headers(client, session.access_token)
      endpoint = Endpoints.sign_out(client, scope)

      case Fetcher.post(endpoint, nil, headers) do
        {:ok, _} -> :ok
        {:error, :not_found} -> :ok
        {:error, :unauthorized} -> :ok
        err -> err
      end
    end
  end

  @impl true
  def invite_user_by_email(client, email, options) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, options} <- InviteUserParams.parse(options),
         redirect_to = %{"redirect_to" => options.redirect_to},
         headers = Fetcher.apply_client_headers(client, nil, redirect_to),
         endpoint = Endpoints.invite(client) do
      Fetcher.post(endpoint, %{email: email, data: options.data}, headers)
    end
  end

  @impl true
  def generate_link(client, attrs) when is_client(client) do
    with {:ok, params} <- GenerateLink.parse(attrs),
         {:ok, client} <- Client.retrieve_client(client),
         redirect_to = %{"redirect_to" => params[:redirect_to]},
         headers = Fetcher.apply_client_headers(client, nil, redirect_to),
         endpoint = Endpoints.generate_link(client),
         {:ok, response} <- Fetcher.post(endpoint, params, headers) do
      GenerateLink.properties(response)
    end
  end

  @impl true
  def create_user(client, attrs) when is_client(client) do
    with {:ok, params} <- AdminUserParams.parse(attrs),
         {:ok, client} <- Client.retrieve_client(client),
         headers = Fetcher.apply_client_headers(client),
         endpoint = Endpoints.create_user(client),
         {:ok, response} <- Fetcher.post(endpoint, params, headers) do
      User.parse(response)
    end
  end
end
