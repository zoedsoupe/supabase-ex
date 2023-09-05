defmodule Supabase.Storage.ObjectOptions do
  @moduledoc false

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
