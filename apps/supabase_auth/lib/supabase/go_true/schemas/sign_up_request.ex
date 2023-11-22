defmodule Supabase.GoTrue.Schemas.SignUpRequest do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Supabase.GoTrue.Schemas.SignUpWithPassword

  @required_fields ~w[password]a
  @optional_fields ~w[email phone data code_challenge code_challenge_method]a

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:phone, :string)
    field(:password, :string)
    field(:data, :map, default: %{})
    field(:code_challenge, :string)
    field(:code_challenge_method, :string)

    embeds_one :gotrue_meta_security, GoTrueMetaSecurity, primary_key: false do
      @derive Jason.Encoder
      field(:captcha_token, :string)
    end
  end

  def changeset(signup \\ %__MODULE__{}, attrs, go_true_meta) do
    signup
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> put_embed(:gotrue_meta_security, go_true_meta)
    |> validate_required(@required_fields)
    |> apply_action(:insert)
  end

  def create(%SignUpWithPassword{} = signup) do
    attrs = SignUpWithPassword.to_sign_up_params(signup)
    go_true_meta = %__MODULE__.GoTrueMetaSecurity{captcha_token: signup.options.captcha_token}

    changeset(attrs, go_true_meta)
  end

  def create(%SignUpWithPassword{} = signup, code_challenge, code_method) do
    attrs = SignUpWithPassword.to_sign_up_params(signup, code_challenge, code_method)
    go_true_meta = %__MODULE__.GoTrueMetaSecurity{captcha_token: signup.options.captcha_token}

    changeset(attrs, go_true_meta)
  end
end
