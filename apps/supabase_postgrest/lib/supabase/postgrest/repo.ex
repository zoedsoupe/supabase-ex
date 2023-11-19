defmodule Supabase.PostgREST.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :supabase_postgrest, adapter: Supabase.PostgREST.EctoAdapter
end
