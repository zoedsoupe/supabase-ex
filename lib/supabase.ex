defmodule Supabase do
  @moduledoc """
  The main entrypoint for the Supabase SDK library.

  ## Starting a Client

  You then can start a Client calling `Supabase.init_client/3`:

      iex> Supabase.init_client("base_url", "api_key", %{db: %{schema: "public"}})
      {:ok, %Supabase.Client{}}

  ## Acknowledgements

  This package represents the base SDK for Supabase. That means
  that it not includes all of the functionality of the Supabase client integrations, so you need to install each feature separetely, as:

  - [Auth/GoTrue](https://github.com/zoedsoupe/gotrue-ex)
  - [Storage](https://github.com/zoedsoupe/storage-ex)
  - [PostgREST](https://github.com/zoedsoupe/postgrest-ex)
  - `Realtime` - TODO
  - `UI` - TODO

  ### Supabase Storage

  Supabase Storage is a service for developers to store large objects like images, videos, and other files. It is a hosted object storage service, like AWS S3, but with a simple API and strong consistency.

  ### Supabase PostgREST

  PostgREST is a web server that turns your PostgreSQL database directly into a RESTful API. The structural constraints and permissions in the database determine the API endpoints and operations.

  ### Supabase Realtime

  Supabase Realtime provides a realtime websocket API powered by PostgreSQL notifications. It allows you to listen to changes in your database, and instantly receive updates as soon as they happen.

  ### Supabase Auth/GoTrue

  Supabase Auth is a feature-complete user authentication system. It provides email & password sign in, email verification, password recovery, session management, and more, out of the box.

  ### Supabase UI

  Supabase UI is a set of UI components that help you quickly build Supabase-powered applications. It is built on top of Tailwind CSS and Headless UI, and is fully customizable. The package provides `Phoenix.LiveView` components!
  """

  alias Supabase.Client

  alias Supabase.MissingSupabaseConfig

  @typep changeset :: Ecto.Changeset.t()

  @spec init_client(String.t(), String.t(), Client.params() | %{}) :: {:ok, Client.t()} | {:error, changeset}
  def init_client(url, api_key, opts \\ %{})
    when is_binary(url) and is_binary(api_key) do
    opts
    |> Map.put(:conn, %{base_url: url, api_key: api_key})
    |> Map.update(:conn, opts, &Map.merge(&1, opts[:conn]))
    |> Client.parse()
  end

  @spec init_client!(String.t, String.t, Client.params | %{}) :: Client.t() | no_return
  def init_client!(url, api_key, %{} = opts \\ %{})
    when is_binary(url) and is_binary(api_key) do
    case init_client(url, api_key, opts) do
      {:ok, client} ->
        client

      {:error, changeset} ->
        errors = errors_on_changeset(changeset)

        if "can't be blank" in (get_in(errors, [:conn, :api_key]) || []) do
          raise MissingSupabaseConfig, key: :key, client: nil
        end

        if "can't be blank" in (get_in(errors, [:conn, :base_url]) || []) do
          raise MissingSupabaseConfig, key: :url, client: nil
        end

        raise Ecto.InvalidChangesetError, changeset: changeset, action: :init
    end
  end

  defp errors_on_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @opaque changeset :: Ecto.Changeset.t()

      @callback changeset(__MODULE__.t(), map) :: changeset
      @callback parse(map) :: {:ok, __MODULE__.t()} | {:error, changeset}

      @optional_callbacks changeset: 2, parse: 1
    end
  end
end
