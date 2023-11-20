defmodule Supabase.PostgREST.EctoAdapter.Connection do
  @moduledoc false

  use Agent

  alias Supabase.PostgREST

  @type opts :: [host: String.t(), schema: String.t()]

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        %PostgREST{}
      end,
      name: __MODULE__
    )
    |> case do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, reason} -> {:error, reason}
    end
  end

  def update(opts) do
    Agent.update(__MODULE__, fn rest ->
      attrs =
        opts
        |> Keyword.take(~w[host schema]a)
        |> Map.new()
        |> Map.update!(:host, &URI.new!/1)

      rest
      |> PostgREST.changeset(attrs)
      |> case do
        {:ok, rest} -> rest
        {:error, _} -> nil
      end
    end)
  end

  @spec apply_connection_change((PostgREST.t() -> PostgREST.t())) :: :ok
  def apply_connection_change(fun) do
    Agent.update(__MODULE__, fun)
  end
end
