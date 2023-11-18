defmodule SupabaseTest do
  use ExUnit.Case, async: true

  alias Supabase.Client
  alias Supabase.ClientRegistry
  alias Supabase.MissingSupabaseConfig

  describe "init_client/1" do
    test "should return a valid PID on valid attrs" do
      {:ok, pid} =
        Supabase.init_client(%{
          name: :test,
          conn: %{
            base_url: "https://test.supabase.co",
            api_key: "test"
          }
        })

      assert pid == ClientRegistry.lookup(:test)
      assert {:ok, client} = Client.retrieve_client(:test)
      assert client.name == :test
      assert client.conn.base_url == "https://test.supabase.co"
      assert client.conn.api_key == "test"
    end

    test "should return an error changeset on invalid attrs" do
      {:error, changeset} = Supabase.init_client(%{})

      assert changeset.errors == [
               name: {"can't be blank", [validation: :required]},
               conn: {"can't be blank", [validation: :required]}
             ]

      {:error, changeset} = Supabase.init_client(%{name: :test, conn: %{}})
      assert conn = changeset.changes.conn

      assert conn.errors == [
               api_key: {"can't be blank", [validation: :required]},
               base_url: {"can't be blank", [validation: :required]}
             ]
    end
  end

  describe "init_client!/1" do
    test "should return a valid PID on valid attrs" do
      pid =
        Supabase.init_client!(%{
          name: :test2,
          conn: %{
            base_url: "https://test.supabase.co",
            api_key: "test"
          }
        })

      assert pid == ClientRegistry.lookup(:test2)
      assert {:ok, client} = Client.retrieve_client(:test2)
      assert client.name == :test2
      assert client.conn.base_url == "https://test.supabase.co"
      assert client.conn.api_key == "test"
    end

    test "should raise MissingSupabaseConfig on missing base_url" do
      assert_raise MissingSupabaseConfig, fn ->
        Supabase.init_client!(%{name: :test, conn: %{api_key: "test"}})
      end
    end

    test "should raise MissingSupabaseConfig on missing api_key" do
      assert_raise MissingSupabaseConfig, fn ->
        Supabase.init_client!(%{name: :test, conn: %{base_url: "https://test.supabase.co"}})
      end
    end
  end
end
