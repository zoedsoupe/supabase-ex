defmodule Supabase.Storage.Bucket do
  @moduledoc "Represents a Bucket on a Supabase Storage"

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
