defmodule Supabase.GoTrue.UserHandler do
  @moduledoc false

  alias Supabase.Client
  alias Supabase.Fetcher
  alias Supabase.GoTrue.PKCE
  alias Supabase.GoTrue.Schemas.SignInRequest
  alias Supabase.GoTrue.Schemas.SignInWithPassword
  alias Supabase.GoTrue.Schemas.SignUpRequest
  alias Supabase.GoTrue.Schemas.SignUpWithPassword
  alias Supabase.GoTrue.User

  @single_user_uri "/user"
  @sign_in_uri "/token"
  @sign_up_uri "/signup"

  def get_user(%Client{} = client, access_token) do
    headers = Fetcher.apply_client_headers(client, access_token)

    client
    |> Client.retrieve_auth_url(@single_user_uri)
    |> Fetcher.get(nil, headers, resolve_json: true)
  end

  @grant_types ~w[password]

  def sign_in_with_password(%Client{} = client, %SignInWithPassword{} = signin) do
    with {:ok, request} <- SignInRequest.create(signin) do
      sign_in_request(client, request, "password")
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

  @code_challenge_method "sha256"

  def sign_up(%Client{} = client, %SignUpWithPassword{} = signup)
      when client.auth.flow_type == "pkce" do
    code_verifier = PKCE.generate_verifier()
    code_challenge = PKCE.generate_challenge(code_verifier)

    with {:ok, request} <- SignUpRequest.create(signup, code_challenge, @code_challenge_method),
         headers = Fetcher.apply_client_headers(client),
         endpoint = Client.retrieve_auth_url(client, @sign_up_uri),
         {:ok, response} <- Fetcher.post(endpoint, request, headers),
         {:ok, user} <- User.parse(response) do
      {:ok, user, code_challenge}
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
end
