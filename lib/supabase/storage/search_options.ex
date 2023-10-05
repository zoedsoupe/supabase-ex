defmodule Supabase.Storage.SearchOptions do
  @moduledoc """
  Represents the search options for querying objects within Supabase Storage.

  This module encapsulates various options that aid in fetching and sorting storage objects. These options include specifying the limit on the number of results, an offset for pagination, and a sorting directive.

  ## Structure

  A `SearchOptions` consists of the following attributes:

  - `limit`: Specifies the maximum number of results to return. Default is `100`.
  - `offset`: Specifies the number of results to skip before starting to fetch the result set. Useful for implementing pagination. Default is `0`.
  - `sort_by`: A map that provides a sorting directive. It defines which column should be used for sorting and the order (ascending or descending). Default is `%{column: "name", order: "asc"}`.

  ## Functions

  - `parse!/1`: Accepts a map of attributes and constructs a structured `SearchOptions`.

  ## Examples

  ### Parsing search options

      search_attrs = %{
        limit: 50,
        offset: 10,
        sort_by: %{column: "created_at", order: "desc"}
      }
      Supabase.Storage.SearchOptions.parse!(search_attrs)
  """

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
