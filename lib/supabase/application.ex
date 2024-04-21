defmodule Supabase.Application do
  @moduledoc false

  use Application

  @finch_opts [name: Supabase.Finch, pools: %{:default => [size: 10]}]

  @impl true
  def start(_start_type, _args) do
    children = [{Finch, @finch_opts}, (if manage_clients?(), do: Supabase.Supervisor)]
    opts = [strategy: :one_for_one, name: Supabase.Supervisor]

    children
    |> Enum.reject(&is_nil/1)
    |> Supervisor.start_link(opts)
  end

  defp manage_clients? do
    Application.get_env(:supabase_potion, :manage_clients, true)
  end
end
