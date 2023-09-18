defmodule Supabase.ConnectionOptions do
  @moduledoc """
  A changeset for validating and parsing connection options. This is mainly
  used internally by `Supabase` module, but can be used to validate and parse
  connection options manually.
  """

  import Ecto.Changeset

  alias Supabase.Types.Atom

  @type t :: %{
          alias: atom,
          name: atom,
          base_url: String.t(),
          api_key: String.t(),
          access_token: String.t(),
          bucket: struct
        }

  @types %{
    base_url: :string,
    api_key: :string,
    access_token: :string,
    bucket: :map,
    alias: Ecto.ParameterizedType.init(Atom, []),
    name: Ecto.ParameterizedType.init(Atom, [])
  }

  @spec parse(map) :: {:ok, Supabase.ConnectionOptions.t()} | {:error, Ecto.Changeset.t()}
  def parse(attrs) do
    {%{}, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required(~w[base_url api_key alias name]a)
    |> apply_action(:parse_connection_options)
  end

  @spec to_connection_info(t) :: Supabase.Connection.params()
  def to_connection_info(data) do
    [
      name: data[:name],
      conn_info: data
    ]
  end
end
