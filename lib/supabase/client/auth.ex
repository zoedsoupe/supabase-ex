defmodule Supabase.Client.Auth do
  @moduledoc """
  Auth configuration schema. This schema is used to configure the auth
  options. This schema is embedded in the `Supabase.Client` schema.

  ## Fields

  - `:auto_refresh_token` - Automatically refresh the token when it expires. Defaults to `true`.
  - `:debug` - Enable debug mode. Defaults to `false`.
  - `:detect_session_in_url` - Detect session in URL. Defaults to `true`.
  - `:flow_type` - Authentication flow type. Defaults to `"implicit"`.
  - `:persist_session` - Persist session. Defaults to `true`.
  - `:storage` - Storage type.
  - `:storage_key` - Storage key. Default to `"sb-$host-auth-token"` where $host is the hostname of your Supabase URL.

  For more information about the auth options, see the documentation for
  the [client](https://supabase.com/docs/reference/javascript/initializing) and
  [auth guides](https://supabase.com/docs/guides/auth)
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          uri: String.t(),
          auto_refresh_token: boolean(),
          debug: boolean(),
          detect_session_in_url: boolean(),
          flow_type: String.t(),
          persist_session: boolean(),
          storage: String.t(),
          storage_key: String.t()
        }

  @type params :: %{
          auto_refresh_token: boolean(),
          debug: boolean(),
          detect_session_in_url: boolean(),
          flow_type: String.t(),
          persist_session: boolean(),
          storage: String.t(),
          storage_key: String.t()
        }

  @storage_key_template "sb-$host-auth-token"

  @primary_key false
  embedded_schema do
    field(:uri, :string, default: "/auth/v1")
    field(:auto_refresh_token, :boolean, default: true)
    field(:debug, :boolean, default: false)
    field(:detect_session_in_url, :boolean, default: true)
    field(:flow_type, Ecto.Enum, values: ~w[implicit pkce magicLink]a, default: :implicit)
    field(:persist_session, :boolean, default: true)
    field(:storage, :string)
    field(:storage_key, :string)
  end

  def changeset(schema, params, supabase_url) do
    schema
    |> cast(
      params,
      ~w[auto_refresh_token debug detect_session_in_url persist_session flow_type storage]a
    )
    |> validate_required(
      ~w[auto_refresh_token debug detect_session_in_url persist_session flow_type]a
    )
    |> put_storage_key(supabase_url)
  end

  defp put_storage_key(%{valid?: false} = changeset, _), do: changeset

  defp put_storage_key(changeset, url) do
    host =
      url
      |> URI.new!()
      |> Map.get(:host)
      |> String.split(".")
      |> List.first()

    storage_key = String.replace(@storage_key_template, "$host", host)
    put_change(changeset, :storage_key, storage_key)
  end
end
