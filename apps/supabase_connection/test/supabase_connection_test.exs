defmodule SupabaseConnectionTest do
  use ExUnit.Case
  doctest SupabaseConnection

  test "greets the world" do
    assert SupabaseConnection.hello() == :world
  end
end
