defmodule Supabase.Client.Conn do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          api_key: String.t(),
          access_token: String.t(),
          base_url: String.t()
        }

  @type params :: %{
          api_key: String.t(),
          access_token: String.t(),
          base_url: String.t()
        }

  @primary_key false
  embedded_schema do
    field(:api_key, :string)
    field(:access_token, :string)
    field(:base_url, :string)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, ~w[api_key access_token base_url]a)
    |> maybe_put_access_token()
    |> validate_required(~w[api_key base_url]a)
  end

  defp maybe_put_access_token(changeset) do
    api_key = get_change(changeset, :api_key)
    token = get_change(changeset, :access_token)

    cond do
      not changeset.valid? -> changeset
      token -> changeset
      true -> put_change(changeset, :access_token, api_key)
    end
  end
end
