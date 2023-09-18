defmodule Supabase.Storage.Object do
  @moduledoc """
  Represents an Object within a Supabase Storage Bucket.

  This module encapsulates the structure and operations related to an object or file stored within a Supabase Storage bucket.

  ## Structure

  An `Object` has the following attributes:

  - `id`: The unique identifier for the object.
  - `path`: The path to the object within its storage bucket.
  - `bucket_id`: The ID of the bucket that houses this object.
  - `name`: The name or title of the object.
  - `owner`: The owner or uploader of the object.
  - `metadata`: A map containing meta-information about the object (e.g., file type, size).
  - `created_at`: Timestamp indicating when the object was first uploaded or created.
  - `updated_at`: Timestamp indicating the last time the object was updated.
  - `last_accessed_at`: Timestamp of when the object was last accessed or retrieved.

  ## Functions

  - `parse!/1`: Accepts a map of attributes and constructs a structured `Object`.

  ## Examples

  ### Parsing an object

      object_attrs = %{
        id: "obj_id",
        path: "/folder/my_file.txt",
        bucket_id: "bucket_123",
        ...
      }
      Supabase.Storage.Object.parse!(object_attrs)
  """

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
