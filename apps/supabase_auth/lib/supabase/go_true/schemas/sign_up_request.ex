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
      field(:captcha_token, :string)
    end
  end

  def create(attrs, nil) do
    %__MODULE__{}
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> apply_action(:insert)
    end

  def create(attrs, %SignUpWithPassword.Options{} = options) do
    go_true_meta = %__MODULE__.GoTrueMetaSecurity{captcha_token: options.captcha_token}
    
    %__MODULE__{}
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> put_assoc(:data, go_true_meta)
    |> validate_required(@required_fields)
    |> apply_action(:insert)
  end
end
