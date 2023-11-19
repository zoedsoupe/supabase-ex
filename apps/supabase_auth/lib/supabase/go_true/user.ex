defmodule Supabase.GoTrue.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Supabase.GoTrue.User.Identity
  alias Supabase.GoTrue.User.Factor

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          app_metadata: map,
          user_metadata: map,
          aud: String.t(),
          confirmation_sent_at: NaiveDateTime.t() | nil,
          recovery_sent_at: NaiveDateTime.t() | nil,
          email_change_sent_at: NaiveDateTime.t() | nil,
          new_email: String.t() | nil,
          new_phone: String.t() | nil,
          invited_at: NaiveDateTime.t() | nil,
          action_link: String.t() | nil,
          email: String.t() | nil,
          phone: String.t() | nil,
          created_at: NaiveDateTime.t(),
          confirmed_at: NaiveDateTime.t() | nil,
          email_confirmed_at: NaiveDateTime.t() | nil,
          phone_confirmed_at: NaiveDateTime.t() | nil,
          last_sign_in_at: NaiveDateTime.t() | nil,
          role: String.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          identities: list(Identity) | nil,
          factors: list(Factor) | nil
        }

  @required_fields ~w[id app_metadata app_metadata aud created_at]a
  @optional_fields ~w[confirmation_sent_at recovery_sent_at email_change_sent_at new_email new_phone invited_at action_link email phone confirmed_at email_confirmed_at phone_confirmed_at last_sign_in_at role]a

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:app_metadata, :map)
    field(:user_metadata, :map)
    field(:aud, :string)
    field(:confirmation_sent_at, :naive_datetime)
    field(:recovery_sent_at, :naive_datetime)
    field(:email_change_sent_at, :naive_datetime)
    field(:new_email, :string)
    field(:new_phone, :string)
    field(:invited_at, :naive_datetime)
    field(:action_link, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:confirmed_at, :naive_datetime)
    field(:email_confirmed_at, :naive_datetime)
    field(:phone_confirmed_at, :naive_datetime)
    field(:last_sign_in_at, :naive_datetime)
    field(:role, :string)

    embeds_many(:factors, Supabase.GoTrue.User.Factor)
    embeds_many(:identities, Supabase.GoTrue.User.Identity)

    timestamps(inserted_at: :created_at)
  end

  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_embed(:identities, required: true)
    |> cast_embed(:factors, required: false)
  end

  def parse(attrs) do
    attrs
    |> changeset()
    |> apply_action(:parse)
  end
end
