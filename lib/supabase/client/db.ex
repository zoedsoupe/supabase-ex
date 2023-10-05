defmodule Supabase.Client.Db do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{schema: String.t()}
  @type params :: %{schema: String.t()}

  embedded_schema do
    field(:schema, :string, default: "public")
  end

  def changeset(schema, params) do
    cast(schema, params, [:schema])
  end
end
