defmodule Supabase.GoTrue.AdminBehaviour do
  @moduledoc false

  alias Supabase.Client
  alias Supabase.GoTrue.Session
  alias Supabase.GoTrue.User

  @type scope :: :global | :local | :others
  @type invite_options :: %{data: map, redirect_to: String.t()}

  @callback sign_out(Client.client(), Session.t(), scope) :: :ok | {:error, atom}
  @callback invite_user_by_email(Client.client(), email, invite_options) :: :ok | {:error, atom}
            when email: String.t()
  @callback generate_link(Client.client(), map) :: {:ok, String.t()} | {:error, atom}
  @callback create_user(Client.client(), map) :: {:ok, User.t()} | {:error, atom}
  @callback list_users(Client.client()) :: {:ok, list(User.t())} | {:error, atom}
  @callback get_user_by_id(Client.client(), Ecto.UUID.t()) :: {:ok, User.t()} | {:error, atom}
  @callback update_user_by_id(Client.client(), Ecto.UUID.t(), map) ::
              {:ok, User.t()} | {:error, atom}
  @callback delete_user(Client.client(), Ecto.UUID.t(), keyword) ::
              {:ok, User.t()} | {:error, atom}
end
