defmodule Supabase.Types.Atom do
  @moduledoc """
  A custom type for Ecto that allows atoms to be used as fields in schemas.
  """

  use Ecto.ParameterizedType

  @impl true
  def type(_), do: :string

  @impl true
  def init(_opts) do
    []
  end

  @impl true
  def cast(v, _opts) when is_atom(v), do: {:ok, v}

  def cast(v, _opts) when is_binary(v),
    do: {:ok, Module.concat(Elixir, String.to_existing_atom(v))}

  @impl true
  def dump(v, _opts, _) when is_atom(v), do: {:ok, Atom.to_string(v)}

  @impl true
  def load(v, _opts, _) when is_binary(v),
    do: {:ok, Module.concat(Elixir, String.to_existing_atom(v))}

  def load(v, _opts, _), do: {:ok, v}
end
