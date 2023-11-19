defmodule Supabase.GoTrue.Schemas.SignInRequest do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Supabase.GoTrue.Schemas.SignInWithPassword

  @required_fields ~w[password]a
  @optional_fields ~w[email phone]a

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:phone, :string)
    field(:password, :string)

    embeds_one :gotrue_meta_security, GoTrueMetaSecurity, primary_key: false do
      field(:captcha_token, :string)
    end
  end

	def create(attrs, nil) do
        %__MODULE__{}
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> apply_action(:insert)
  end

  def create(attrs, %SignInWithPassword.Options{} = options) do
		gotrue_meta = %__MODULE__.GoTrueMetaSecurity{captcha_token: options.captcha_token}

    %__MODULE__{}
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> put_embed(:gotrue_meta_security, gotrue_meta, required: true)
    |> validate_required(@required_fields)
    |> apply_action(:insert)
  end
end
