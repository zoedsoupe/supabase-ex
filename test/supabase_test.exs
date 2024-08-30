defmodule SupabaseTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset

  alias Supabase.Client
  alias Supabase.MissingSupabaseConfig

  describe "init_client/1" do
    test "should return a valid client on valid attrs" do
      {:ok, %Client{} = client} =
        Supabase.init_client(%{
          conn: %{
            base_url: "https://test.supabase.co",
            api_key: "test"
          }
        })

      assert client.conn.base_url == "https://test.supabase.co"
      assert client.conn.api_key == "test"
    end

    test "should return an error changeset on invalid attrs" do
      {:error, changeset} = Supabase.init_client(%{})
      conn = get_change(changeset, :conn)

      assert conn.errors == [
               api_key: {"can't be blank", [validation: :required]},
               base_url: {"can't be blank", [validation: :required]}
             ]

      {:error, changeset} = Supabase.init_client(%{conn: %{}})
      conn = get_change(changeset, :conn)

      assert conn.errors == [
               api_key: {"can't be blank", [validation: :required]},
               base_url: {"can't be blank", [validation: :required]}
             ]
    end
  end

  describe "init_client!/1" do
    test "should return a valid client on valid attrs" do
      assert %Client{} = client =
        Supabase.init_client!(%{
          conn: %{
            base_url: "https://test.supabase.co",
            api_key: "test"
          }
        })

      assert client.conn.base_url == "https://test.supabase.co"
      assert client.conn.api_key == "test"
    end

    test "should raise MissingSupabaseConfig on missing base_url" do
      assert_raise MissingSupabaseConfig, fn ->
        Supabase.init_client!(%{conn: %{api_key: "test"}})
      end
    end

    test "should raise MissingSupabaseConfig on missing api_key" do
      assert_raise MissingSupabaseConfig, fn ->
        Supabase.init_client!(%{conn: %{base_url: "https://test.supabase.co"}})
      end
    end
  end
end
