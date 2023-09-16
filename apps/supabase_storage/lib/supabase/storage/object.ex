defmodule Supabase.Storage.Object do
  @moduledoc "Represents a Object on a Supabase Storage"

  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, apply_action!: 2]

  @type t :: %__MODULE__{
          id: String.t(),
          path: Path.t(),
          bucket_id: String.t(),
          name: String.t(),
          owner: String.t(),
          metadata: map(),
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          last_accessed_at: NaiveDateTime.t()
        }

  @fields ~w(id path bucket_id name owner created_at updated_at metadata last_accessed_at)a

  @primary_key false
  embedded_schema do
    field(:path, :string)
    field(:id, :string)
    field(:bucket_id, :string)
    field(:name, :string)
    field(:owner, :string)
    field(:metadata, :map)
    field(:created_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
    field(:last_accessed_at, :naive_datetime)
  end

  @spec parse!(map) :: t
  def parse!(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> apply_action!(:parse)
  end
end
