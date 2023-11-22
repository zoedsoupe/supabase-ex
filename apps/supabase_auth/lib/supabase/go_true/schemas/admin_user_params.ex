defmodule Supabase.GoTrue.Schemas.AdminUserParams do
  @moduledoc false

  import Ecto.Changeset

  @types %{
    app_metadata: :map,
    email_confirm: :boolean,
    phone_confirm: :boolean,
    ban_duration: :string,
    role: :string,
    email: :string,
    phone: :string,
    password: :string,
    nonce: :string
  }

  def parse(attrs) do
    {%{}, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required_inclusion([:email, :phone])
    |> apply_action(:parse)
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
