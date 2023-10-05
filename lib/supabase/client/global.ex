defmodule Supabase.Client.Global do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{headers: Map.t()}
  @type params :: %{headers: Map.t()}

  embedded_schema do
    field(:headers, {:map, :string}, default: %{})
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:headers])
    |> validate_required([:headers])
  end
end
