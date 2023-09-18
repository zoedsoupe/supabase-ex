defmodule Supabase.Storage.Bucket do
  @moduledoc """
  Represents a Bucket on Supabase Storage.

  This module defines the structure and operations related to a storage bucket on Supabase.

  ## Structure

  A `Bucket` consists of:

  - `id`: The unique identifier for the bucket.
  - `name`: The display name of the bucket.
  - `owner`: The owner of the bucket.
  - `file_size_limit`: The maximum file size allowed in the bucket (in bytes). Can be `nil` for no limit.
  - `allowed_mime_types`: List of MIME types permitted in this bucket. Can be `nil` for no restrictions.
  - `created_at`: Timestamp indicating when the bucket was created.
  - `updated_at`: Timestamp indicating the last update to the bucket.
  - `public`: Boolean flag determining if the bucket is publicly accessible or not.

  ## Functions

  - `parse!/1`: Parses and returns a bucket structure.
  - `create_changeset/1`: Generates a changeset for creating a bucket.
  - `update_changeset/2`: Generates a changeset for updating an existing bucket.

  ## Examples

  ### Parsing a bucket

      bucket_attrs = %{
        id: "bucket_id",
        name: "My Bucket",
        ...
      }
      Supabase.Storage.Bucket.parse!(bucket_attrs)

  ### Creating a bucket changeset

      new_bucket_attrs = %{
        id: "new_bucket_id",
        ...
      }
      Supabase.Storage.Bucket.create_changeset(new_bucket_attrs)

  ### Updating a bucket

      existing_bucket = %Supabase.Storage.Bucket{
        id: "existing_bucket_id",
        ...
      }
      updated_attrs = %{
        public: true
      }
      Supabase.Storage.Bucket.update_changeset(existing_bucket, updated_attrs)
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          owner: String.t(),
          file_size_limit: integer | nil,
          allowed_mime_types: list(String.t()) | nil,
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          public: boolean
        }

  @fields ~w(id name created_at updated_at file_size_limit allowed_mime_types public owner)a
  @create_fields ~w(id name file_size_limit allowed_mime_types public)a
  @update_fields ~w(file_size_limit allowed_mime_types public)a

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:owner, :string)
    field(:file_size_limit, :integer)
    field(:allowed_mime_types, {:array, :string})
    field(:created_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
    field(:public, :boolean, default: false)
  end

  @spec parse!(map) :: t
  def parse!(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> apply_action!(:parse)
  end

  @spec create_changeset(map) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @create_fields)
    |> validate_required([:id])
    |> maybe_put_name()
    |> apply_action(:create)
    |> case do
      {:ok, data} -> {:ok, Map.take(data, @create_fields)}
      err -> err
    end
  end

  defp maybe_put_name(changeset) do
    if get_change(changeset, :name) do
      changeset
    else
      id = get_change(changeset, :id)
      put_change(changeset, :name, id)
    end
  end

  @spec update_changeset(t, map) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def update_changeset(%__MODULE__{} = bucket, attrs) do
    bucket
    |> cast(attrs, @update_fields)
    |> apply_action(:update)
    |> case do
      {:ok, data} -> {:ok, Map.take(data, @update_fields)}
      err -> err
    end
  end
end
