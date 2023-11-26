defmodule Supabase.GoTrue.Schemas.SignInRequest do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Supabase.GoTrue.Schemas.SignInWithIdToken
  alias Supabase.GoTrue.Schemas.SignInWithPassword

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:phone, :string)
    field(:password, :string)
    field(:provider, :string)
    field(:access_token, :string)
    field(:nonce, :string)
    field(:id_token, :string)

    embeds_one :gotrue_meta_security, GoTrueMetaSecurity, primary_key: false do
      @derive Jason.Encoder
      field(:captcha_token, :string)
    end
  end

  def create(%SignInWithIdToken{} = signin) do
    attrs = SignInWithIdToken.to_sign_in_params(signin)
    gotrue_meta = %__MODULE__.GoTrueMetaSecurity{captcha_token: signin.options.captcha_token}

    %__MODULE__{}
    |> cast(attrs, [:provider, :id_token, :access_token, :nonce])
    |> put_embed(:gotrue_meta_security, gotrue_meta, required: true)
    |> validate_required([:provider, :id_token])
    |> apply_action(:insert)
  end

  def create(%SignInWithPassword{} = signin) do
    attrs = SignInWithPassword.to_sign_in_params(signin)
    gotrue_meta = %__MODULE__.GoTrueMetaSecurity{captcha_token: signin.options.captcha_token}

    %__MODULE__{}
    |> cast(attrs, [:email, :phone, :password])
    |> put_embed(:gotrue_meta_security, gotrue_meta, required: true)
    |> validate_required([:password])
    |> validate_required_inclusion([:email, :phone])
    |> apply_action(:insert)
  end

  defp validate_required_inclusion(%{valid?: false} = c, _), do: c

  defp validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, &present?(changeset, &1)) do
      changeset
    else
      changeset
      |> add_error(:email, "at least an email or phone is required")
      |> add_error(:phone, "at least an email or phone is required")
    end
  end

  defp present?(changeset, field) do
    value = get_change(changeset, field)
    value && value != ""
  end
end
