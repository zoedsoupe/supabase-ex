defmodule Supabase.GoTrue.UserHandler do
  @moduledoc false

  alias Supabase.Client
  alias Supabase.Fetcher
  alias Supabase.GoTrue.PKCE
  alias Supabase.GoTrue.Schemas.SignInRequest
  alias Supabase.GoTrue.Schemas.SignInWithIdToken
  alias Supabase.GoTrue.Schemas.SignInWithOauth
  alias Supabase.GoTrue.Schemas.SignInWithPassword
  alias Supabase.GoTrue.Schemas.SignUpRequest
  alias Supabase.GoTrue.Schemas.SignUpWithPassword
  alias Supabase.GoTrue.User

  @single_user_uri "/user"
  @sign_in_uri "/token"
  @sign_up_uri "/signup"
  @oauth_uri "/authorize"
  @sso_uri "/sso"

  def get_user(%Client{} = client, access_token) do
    headers = Fetcher.apply_client_headers(client, access_token)

    client
    |> Client.retrieve_auth_url(@single_user_uri)
    |> Fetcher.get(nil, headers, resolve_json: true)
  end

  def sign_in_with_sso(%Client{} = client, %{} = signin) when client.auth.flow_type == :pkce do
    {challenge, method} = generate_pkce()

    with {:ok, request} <- %{},
         headers = Fetcher.apply_client_headers(client),
         endpoint = Client.retrieve_auth_url(client, @sso_uri),
         {:ok, response} <- Fetcher.post(endpoint, request, headers) do
      {:ok, response["data"]["url"]}
    end
  end

  def sign_in_with_sso(%Client{} = client, %{} = signin) do
    with {:ok, request} <- %{},
         headers = Fetcher.apply_client_headers(client),
         endpoint = Client.retrieve_auth_url(client, @sso_uri),
         {:ok, response} <- Fetcher.post(endpoint, request, headers) do
      {:ok, response["data"]["url"]}
    end
  end

  @grant_types ~w[password id_token]

  def sign_in_with_password(%Client{} = client, %SignInWithPassword{} = signin) do
    with {:ok, request} <- SignInRequest.create(signin) do
      sign_in_request(client, request, "password")
    end
  end

  def sign_in_with_id_token(%Client{} = client, %SignInWithIdToken{} = signin) do
    with {:ok, request} <- SignInRequest.create(signin) do
      sign_in_request(client, request, "id_token")
    end
  end

  defp sign_in_request(%Client{} = client, %SignInRequest{} = request, grant_type)
       when grant_type in @grant_types do
    query = URI.encode_query(%{grant_type: grant_type})
    headers = Fetcher.apply_client_headers(client)

    client
    |> Client.retrieve_auth_url(@sign_in_uri)
    |> URI.append_query(query)
    |> Fetcher.post(request, headers)
  end

  def sign_up(%Client{} = client, %SignUpWithPassword{} = signup)
      when client.auth.flow_type == :pkce do
    {challenge, method} = generate_pkce()

    with {:ok, request} <- SignUpRequest.create(signup, challenge, method),
         headers = Fetcher.apply_client_headers(client),
         endpoint = Client.retrieve_auth_url(client, @sign_up_uri),
         {:ok, response} <- Fetcher.post(endpoint, request, headers),
         {:ok, user} <- User.parse(response) do
      {:ok, user, challenge}
    end
  end

  def sign_up(%Client{} = client, %SignUpWithPassword{} = signup) do
    with {:ok, request} <- SignUpRequest.create(signup),
         headers = Fetcher.apply_client_headers(client),
         endpoint = Client.retrieve_auth_url(client, @sign_up_uri),
         {:ok, response} <- Fetcher.post(endpoint, request, headers) do
      User.parse(response)
    end
  end

  def get_url_for_provider(%Client{} = client, %SignInWithOauth{} = oauth)
      when client.auth.flow_type == :pkce do
    {challenge, method} = generate_pkce()
    pkce_query = %{code_challenge: challenge, code_challenge_method: method}
    oauth_query = SignInWithOauth.options_to_query(oauth)

    client
    |> Client.retrieve_auth_url(@oauth_uri)
    |> append_query(Map.merge(pkce_query, oauth_query))
  end

  def get_url_for_provider(%Client{} = client, %SignInWithOauth{} = oauth) do
    oauth_query = SignInWithOauth.options_to_query(oauth)

    client
    |> Client.retrieve_auth_url(@oauth_uri)
    |> append_query(oauth_query)
  end

  defp append_query(%URI{} = uri, query) do
    query = Map.filter(query, &(not is_nil(elem(&1, 1))))
    encoded = URI.encode_query(query)
    URI.append_query(uri, encoded)
  end

  defp generate_pkce do
    verifier = PKCE.generate_verifier()
    challenge = PKCE.generate_challenge(verifier)
    method = if verifier == challenge, do: "plain", else: "s256"
    {challenge, method}
  end
end
