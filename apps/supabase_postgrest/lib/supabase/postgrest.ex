defmodule Supabase.PostgREST do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Supabase.Client
  alias Supabase.Fetcher

  @type t :: %__MODULE__{
          path: URI.t(),
          headers: map,
          schema: String.t(),
          method: :get | :post | :put | :delete,
          body: map,
          params: list(String.t())
        }

  @default_path "/rest/v1"

  @default_headers %{
    "accept" => "application/json",
    "content-type" => "application/json",
    "content-profile" => "$schema",
    "accept-profile" => "$schema"
  }

  @primary_key false
  embedded_schema do
    field(:host, :map, default: URI.new!("http://localhost:3000"))
    field(:path, :map, default: URI.new!(@default_path))
    field(:headers, {:map, :string})
    field(:schema, :string, default: "public")
    field(:method, Ecto.Enum, values: ~w[get post put delete]a, default: :get)
    field(:body, :map)
    field(:params, {:array, :string})

    field(:url, :string, virtual: true)
  end

  def to_map(%__MODULE__{} = rest) do
    rest
    |> Map.from_struct()
    |> Map.put(:url, URI.to_string(URI.merge(rest.host, rest.path)))
    |> Map.update(:headers, rest.headers, &Map.to_list/1)
  end

  @doc false
  def changeset(rest \\ %__MODULE__{}, attrs) do
    rest
    |> cast(attrs, [:host, :path, :headers, :schema, :method, :body, :params])
    |> maybe_merge_headers()
    |> validate_required([:method, :headers])
    |> apply_action(:parse)
  end

  defp maybe_merge_headers(%{valid?: false} = changeset), do: changeset

  defp maybe_merge_headers(changeset) do
    headers = get_change(changeset, :headers)
    schema = get_change(changeset, :schema) || get_field(changeset, :schema)

    merged =
      @default_headers
      |> Map.replace("content-profile", schema)
      |> Map.replace("accept-profile", schema)
      |> Map.merge(headers || %{})

    put_change(changeset, :headers, merged)
  end

  @spec from_supabase_client(Client.t()) :: {:ok, __MODULE__.t()} | {:error, Ecto.Changeset.t()}
  def from_supabase_client(%Client{} = client) do
    with {:ok, rest} <-
           changeset(%{
             schema: client.db.schema,
             host: URI.new!(client.conn.base_url),
             method: :get,
             headers: client.global.headers
           }) do
      __MODULE__.schema(rest, client.db.schema)
    end
  end

  @spec from(__MODULE__.t(), String.t()) :: __MODULE__.t() | {:error, Ecto.Changeset.t()}
  def from(%__MODULE__{} = rest, relation) do
    with {:ok, rest} <- changeset(rest, %{path: URI.merge(rest.path, relation)}) do
      rest
    end
  end

  @spec schema(__MODULE__.t(), String.t()) :: __MODULE__.t() | {:error, Ecto.Changeset.t()}
  def schema(%__MODULE__{} = rest, schema) do
    headers = %{"accept-profile" => schema, "content-profile" => schema}

    with {:ok, rest} <- changeset(rest, %{headers: headers, schema: schema, method: :get}) do
      rest
    end
  end

  @spec call(__MODULE__.t()) :: Finch.Response.t()
  def call(%__MODULE__{} = rest) do
    req = to_map(rest)

    task =
      Task.async(fn ->
        cond do
          req.method in [:get, :delete] ->
            apply(Fetcher, req.method, [req.url, req.headers])

          req.method in [:put, :post] ->
            apply(Fetcher, req.method, [req.url, req.body, req.headers])
        end
      end)

    Task.await(task)
  end

  @spec ping(__MODULE__.t()) :: :pong | :error
  def ping(%__MODULE__{} = rest) do
    {:ok, temp} = changeset(rest, %{schema: "", method: :get})

    case call(temp) do
      {:ok, _result} -> :pong
      _ -> :error
    end
  end
end
