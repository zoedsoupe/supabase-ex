defmodule Supabase.GoTrue.User.Identity do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          provider: providers,
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          identity_data: map,
          last_sign_in_at: NaiveDateTime.t() | nil
        }

  @providers ~w[apple azure bitbucket discord email facebook figma github gitlab google kakao keycloak linkedin linkedin_oidc notion phone slack spotify twitch twitter workos zoom fly]a

  @type providers ::
          unquote(@providers |> Enum.map_join(" | ", &inspect/1) |> Code.string_to_quoted!())

  @required_fields ~w[id provider]a
  @optional_fields ~w[identity_data last_sign_in_at created_at updated_at user_id]a

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:identity_data, :map)
    field(:provider, Ecto.Enum, values: @providers)
    field(:last_sign_in_at, :naive_datetime)

    belongs_to(:user, Supabase.GoTrue.User, type: :binary_id)

    timestamps(inserted_at: :created_at)
  end

  def changeset(identifty \\ %__MODULE__{}, attrs) do
    identifty
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def providers, do: @providers
end
