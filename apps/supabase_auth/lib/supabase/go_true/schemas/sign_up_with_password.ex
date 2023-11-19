defmodule Supabase.GoTrue.Schemas.SignUpWithPassword do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type options :: %__MODULE__.Options{
          email_redirect_to: URI.t() | nil,
          data: map | nil,
          captcha_token: String.t() | nil
        }

  @type t :: %__MODULE__{
          email: String.t() | nil,
          password: String.t(),
          phone: String.t() | nil,
          options: list(options) | nil
        }

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:password, :string)
    field(:phone, :string)

    embeds_one :options, Options, primary_key: false do
      field(:email_redirect_to, :map)
      field(:data, :map)
      field(:captcha_token, :string)
    end
  end

  @spec validate(map) :: Ecto.Changeset.t()
  def validate(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email, :password, :phone])
    |> cast_embed(:options, with: &options_changeset/2, required: false)
    |> validate_email_or_phone()
    |> validate_required([:password])
  end
  
  defp options_changeset(options, attrs) do
    cast(options, attrs, ~w[email_redirect_to data captcha_token]a)
  end

  defp validate_email_or_phone(changeset) do
    email = get_change(changeset, :email)
    phone = get_change(changeset, :phone)

    case {email, phone} do
      {nil, nil} ->
        changeset
        |> add_error(:email, "or phone can't be blank")
        |> add_error(:phone, "or email can't be blank")

      {email, nil} when is_binary(email) -> changeset
      {nil, phone} when is_binary(phone) -> changeset

      {email, phone} when is_binary(email) and is_binary(phone) -> 
        changeset
        |> add_error(:email, "can't be given with phone")
        |> add_error(:phone, "can't be given with email")
    end
  end

  @spec parse(map) :: {:ok, t} | {:error, Ecto.Changeset.t()}
  def parse(attrs) do
    attrs
    |> validate()
    |> apply_action(:parse)
  end
end
