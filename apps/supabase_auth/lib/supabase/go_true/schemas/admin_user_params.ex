defmodule Supabase.GoTrue.Schemas.AdminUserParams do
  @moduledoc false

  import Ecto.Changeset

  @types %{
    app_metadata: :map,
    email_confirm: :boolean,
    phone_confirm: :boolean,
    ban_duration: :string,
    role: :string
  }

  def parse(attrs) do
    {%{}, @types}
    |> cast(attrs, Map.keys(@types))
    |> apply_action(:parse)
  end
end
