defmodule Supabase.GoTrue.Schemas.SignInWithPassword do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:phone, :string)
    field(:password, :string)

    embeds_one :options, Options, primary_key: false do
      field(:data, :map)
      field(:captcha_token, :string)
    end
  end

  def to_sign_in_params(%__MODULE__{} = signin) do
    Map.take(signin, [:email, :phone, :password])
  end

  def parse(attrs) do
    %__MODULE__{}
    |> cast(attrs, ~w[email phone password]a)
    |> cast_embed(:options, with: &options_changeset/2, required: false)
    |> validate_required([:password])
    |> maybe_put_default_options()
    |> apply_action(:parse)
  end

  defp maybe_put_default_options(%{valid?: false} = c), do: c

  defp maybe_put_default_options(changeset) do
    if get_embed(changeset, :options) do
      changeset
    else
      put_embed(changeset, :options, %__MODULE__.Options{})
    end
  end

  defp options_changeset(options, attrs) do
    cast(options, attrs, ~w[email_redirect_to data captcha_token]a)
  end
end
