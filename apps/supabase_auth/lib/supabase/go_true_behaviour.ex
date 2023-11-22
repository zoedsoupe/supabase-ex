defmodule Supabase.GoTrueBehaviour do
  @moduledoc false

  alias Supabase.Client
  alias Supabase.GoTrue.Schemas.SignInWithOauth
  alias Supabase.GoTrue.Schemas.SignInWithPassword
  alias Supabase.GoTrue.Schemas.SignUpWithPassword
  alias Supabase.GoTrue.Session
  alias Supabase.GoTrue.User

  @type sign_in_response ::
          {:ok, Session.t()}
          | {:error, :invalid_grant}
          | {:error, {:invalid_grant, :invalid_credentials}}

  @callback get_user(Client.client(), Session.t()) :: {:ok, User.t()} | {:error, atom}
  @callback sign_in_with_oauth(Client.client(), SignInWithOauth.t()) :: {:ok, atom, URI.t()}
  @callback sign_in_with_password(Client.client(), SignInWithPassword.t()) ::
              {:ok, Session.t()} | sign_in_response
  @callback sign_up(Client.client(), SignUpWithPassword.t()) ::
              {:ok, User.t(), binary} | {:error, atom}
end
