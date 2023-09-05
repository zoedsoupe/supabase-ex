defmodule Supabase.Storage.SearchOptions do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, apply_action!: 2]

  @type t :: %__MODULE__{
          limit: integer(),
          offset: integer(),
          sort_by: %{
            column: String.t(),
            order: String.t()
          }
        }

  @fields ~w(limit offset sort_by)a

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:limit, :integer, default: 100)
    field(:offset, :integer, default: 0)
    field(:sort_by, :map, default: %{column: "name", order: "asc"})
  end

  @spec parse!(map) :: t
  def parse!(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> apply_action!(:parse)
  end
end
