defmodule Supabase.Storage.ObjectOptions do
  @moduledoc """
  Represents the configurable options for an Object within Supabase Storage.

  This module encapsulates options that can be set or modified for a storage object. These options help in controlling behavior such as caching, content type, and whether to upsert an object.

  ## Structure

  An `ObjectOptions` consists of the following attributes:

  - `cache_control`: Specifies directives for caching mechanisms in both requests and responses. Default is `"3600"`.
  - `content_type`: Specifies the media type of the resource or data. Default is `"text/plain;charset=UTF-8"`.
  - `upsert`: A boolean that, when set to `true`, will insert the object if it does not exist, or update it if it does. Default is `true`.

  ## Functions

  - `parse!/1`: Accepts a map of attributes and constructs a structured `ObjectOptions`.

  ## Examples

  ### Parsing object options

      options_attrs = %{
        cache_control: "no-cache",
        content_type: "application/json",
        upsert: false
      }
      Supabase.Storage.ObjectOptions.parse!(options_attrs)
  """

  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, apply_action!: 2]

  @type t :: %__MODULE__{
          cache_control: String.t(),
          content_type: String.t(),
          upsert: boolean()
        }

  @fields ~w(cache_control content_type upsert)a

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field(:cache_control, :string, default: "3600")
    field(:content_type, :string, default: "text/plain;charset=UTF-8")
    field(:upsert, :boolean, default: true)
  end

  @spec parse!(map) :: t
  def parse!(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> apply_action!(:parse)
  end
end
