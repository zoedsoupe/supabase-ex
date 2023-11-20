defmodule Supabase.GoTrue.Admin do
  @moduledoc false

  import Supabase.Client, only: [is_client: 1]

  alias Supabase.Client
  alias Supabase.Fetcher
  alias Supabase.GoTrue.AdminHandler
  alias Supabase.GoTrue.User
  alias Supabase.GoTrue.Schemas.AdminUserParams
  alias Supabase.GoTrue.Schemas.GenerateLink
  alias Supabase.GoTrue.Schemas.InviteUserParams
  alias Supabase.GoTrue.Schemas.PaginationParams
  alias Supabase.GoTrue.Session

  @behaviour Supabase.GoTrue.AdminBehaviour

  @scopes ~w[global local others]a

  @impl true
  def sign_out(client, %Session{} = session, scope) when is_client(client) and scope in @scopes do
    with {:ok, client} <- Client.retrieve_client(client) do
      case AdminHandler.sign_out(client, session.access_token, scope) do
        {:ok, _} -> :ok
        {:error, :not_found} -> :ok
        {:error, :unauthorized} -> :ok
        err -> err
      end
    end
  end

  @impl true
  def invite_user_by_email(client, email, options \\ %{}) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, options} <- InviteUserParams.parse(options),
         {:ok, response} <- AdminHandler.invite_user(client, email, options) do
      User.parse(response)
    end
  end

  @impl true
  def generate_link(client, attrs) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, params} <- GenerateLink.parse(attrs),
         {:ok, response} <- AdminHandler.generate_link(client, params) do
      GenerateLink.properties(response)
    end
  end

  @impl true
  def create_user(client, attrs) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, params} <- AdminUserParams.parse(attrs),
         {:ok, response} <- AdminHandler.create_user(client, params) do
      User.parse(response)
    end
  end

  @impl true
  def delete_user(client, user_id, opts \\ [should_soft_delete: false]) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, _} <- AdminHandler.delete_user(client, user_id, opts) do
      :ok
    end
  end

  @impl true
  def get_user_by_id(client, user_id) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, response} <- AdminHandler.get_user(client, user_id) do
      User.parse(response)
    end
  end

  @impl true
  def list_users(client, params \\ %{}) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, params} <- PaginationParams.page_params(params),
         {:ok, response} <- AdminHandler.list_users(client, params),
         {:ok, users} <- User.parse_list(response.body["users"]) do
      total = Fetcher.get_header(response, "x-total-count")

      links =
        response
        |> Fetcher.get_header("link", "")
        |> String.split(",", trim: true)

      next = parse_next_page_count(links)
      last = parse_last_page_count(links)

      attrs = %{next_page: (next != 0 && next) || nil, last_page: last, total: total}
      {:ok, pagination} = PaginationParams.pagination(attrs)

      {:ok, users, pagination}
    end
  end

  @next_page_rg ~r/.+\?page=(\d).+rel=\"next\"/
  @last_page_rg ~r/.+\?page=(\d).+rel=\"last\"/

  defp parse_next_page_count(links) do
    parse_page_count(links, @next_page_rg)
  end

  defp parse_last_page_count(links) do
    parse_page_count(links, @last_page_rg)
  end

  defp parse_page_count(links, regex) do
    Enum.reduce_while(links, 0, fn link, acc ->
      case Regex.run(regex, link) do
        [_, page] -> {:halt, page}
        _ -> {:cont, acc}
      end
    end)
  end

  @impl true
  def update_user_by_id(client, user_id, attrs) when is_client(client) do
    with {:ok, client} <- Client.retrieve_client(client),
         {:ok, params} <- AdminUserParams.parse(attrs),
         {:ok, response} <- AdminHandler.update_user(client, user_id, params) do
      User.parse(response)
    end
  end
end
