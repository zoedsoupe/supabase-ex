defmodule Supabase.Client.Db do
  @moduledoc """
  DB configuration schema. This schema is used to configure the database
  options. This schema is embedded in the `Supabase.Client` schema.

  ## Fields

  - `:schema` - The default schema to use. Defaults to `"public"`.

  For more information about the database options, see the documentation for
  the [client](https://supabase.com/docs/reference/javascript/initializing) and
  [database guides](https://supabase.com/docs/guides/database).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{schema: String.t()}
  @type params :: %{schema: String.t()}

  @primary_key false
  embedded_schema do
    field(:schema, :string, default: "public")
  end

  def changeset(schema, params) do
    cast(schema, params, [:schema])
  end
end
