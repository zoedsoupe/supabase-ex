defmodule Supabase.GoTrue do
  @moduledoc false

  import Supabase.Client, only: [is_client: 1]

  alias Supabase.GoTrue.Endpoints
  alias Supabase.GoTrue.PKCE
  alias Supabase.GoTrue.User
  alias Supabase.GoTrue.Session
  alias Supabase.GoTrue.Schemas.SignInRequest
  alias Supabase.GoTrue.Schemas.SignInWithPassword
  alias Supabase.GoTrue.Schemas.SignUpRequest
  alias Supabase.GoTrue.Schemas.SignUpWithPassword
  alias Supabase.Client
  alias Supabase.Fetcher

  @opaque client :: pid | module

  @behaviour Supabase.GoTrueBehaviour

  @impl true
  def get_user(client, %Session{} = session) do
    with {:ok, client} <- Client.retrieve_client(client),
         uri = Endpoints.user(client),
         headers = Fetcher.apply_client_headers(client, session.access_token),
         {:ok, response} <- Fetcher.get(uri, headers) do
      User.parse(response)
    end
  end

  @impl true
  def sign_in_with_password(client, credentials) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, credentials} <- SignInWithPassword.parse(credentials),
         attrs = %{
           email: credentials.email,
           phone: credentials.phone,
           password: credentials.password
         },
         {:ok, params} <- SignInRequest.create(attrs, credentials.options) do
      sign_in_request(params, client)
    end
  end

  defp sign_in_request(%SignInRequest{} = request, %Client{} = client) do
    headers = api_headers(client)

    with uri = Endpoints.sign_in(client, "password"),
         {:ok, response} <- Fetcher.post(uri, request, headers) do
      Session.parse(response, response["user"])
    end
  end

  @impl true
  def sign_up(client, credentials) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, credentials} <- SignUpWithPassword.parse(credentials) do
      if client.auth.flow_type == :pkce do
        sign_up_with_pkce(credentials, client)
      else
        sign_up_without_pkce(credentials, client)
      end
    end
  end

  defp sign_up_with_pkce(%SignUpWithPassword{} = credentials, %Client{} = client) do
    code_verifier = PKCE.generate_verifier()
    code_challenge = PKCE.generate_challenge(code_verifier)
    code_challenge_method = "sha256"

    attrs = %{
      email: credentials.email,
      phone: credentials.phone,
      password: credentials.password,
      code_challenge: code_challenge,
      code_challenge_method: code_challenge_method
    }

    with {:ok, params} <- SignUpRequest.create(attrs, credentials.options),
         {:ok, response} <- sign_up_request(params, client) do
      {:ok, response, code_challenge}
    end
  end

  defp sign_up_without_pkce(%SignUpWithPassword{} = credentials, %Client{} = client) do
    attrs = %{email: credentials.email, phone: credentials.phone, password: credentials.password}

    with {:ok, params} <- SignUpRequest.create(attrs, credentials.options),
         {:ok, user} <- sign_up_request(params, client) do
      {:ok, user, nil}
    end
  end

  defp sign_up_request(%SignUpRequest{} = request, %Client{} = client) do
    # add xform and redirect_to options to request
    headers = api_headers(client)

    with uri = Endpoints.sign_up(client),
         {:ok, response} <- Fetcher.post(uri, request, headers) do
      User.parse(response)
    end
  end

  defp api_headers(%Client{} = client) do
    Fetcher.apply_headers(client.conn.api_key, client.conn.access_token, client.global.headers)
  end
end
