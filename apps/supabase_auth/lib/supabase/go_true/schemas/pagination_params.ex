defmodule Supabase.GoTrue.Schemas.PaginationParams do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  def page_params(attrs) do
    schema = %{page: :integer, per_page: :integer}

    {%{}, schema}
    |> cast(attrs, Map.keys(schema))
    |> apply_action(:parse)
  end

  def pagination(attrs) do
    schema = %{next_page: :integer, last_page: :integer, total: :integer}

    {%{}, schema}
    |> cast(attrs, Map.keys(schema))
    |> validate_required([:total, :last_page])
    |> apply_action(:parse)
  end
end
