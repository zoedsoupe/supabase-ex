# Supabase Connection

The **Supabase Connection** is a fundamental component of the Supabase ecosystem, designed to streamline your interaction with the Supabase platform from your Elixir applications. This package enables you to manage connections to Supabase, allowing you to perform various operations on Supabase services such as storage, authentication, and more.

## Starting a Connection

The core concept of this package is the `Supabase.Connection`, which represents your connection to Supabase. You can start a connection using the `Supabase.Connection.start_link/1` function. For example:

```elixir
iex> Supabase.Connection.start_link(name: :my_conn, conn_info: %{base_url: "https://myapp.supabase.io", api_key: "my_api_key"})
{:ok, #PID<0.123.0>}
```

However, it's more common to add the connection to your supervision tree for better management. Here's an example of how to do this in your application module:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    conn_info = %{base_url: "https://myapp.supabase.io", api_key: "my_api_key"}

    children = [
      {Supabase.Connection, conn_info: conn_info, name: :my_conn}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Using Connections

Once you have started a connection, you can use it to perform various operations on Supabase services. For example, you can list all the buckets in the storage service:

```elixir
iex> conn = Supabase.Connection.fetch_current_bucket!(:my_conn)
iex> Supabase.Storage.list_buckets(conn)
{:ok, [
  %Supabase.Storage.Bucket{
    allowed_mime_types: nil,
    file_size_limit: nil,
    id: "my-bucket-id",
    name: "my-bucket",
    public: true
  }
]}
```

You can start multiple connections, each with different credentials, to perform operations on different buckets.

## Configuration and Fields

A `Supabase.Connection` holds various fields, including:

- `:base_url`: The base URL of the Supabase API.
- `:api_key`: The API key used for authentication.
- `:access_token`: A token with specific permissions.
- `:name`: A simple field to track the name of the connection.
- `:alias`: A field to manage multiple connections on a `Supabase.Client` Agent.

## Acknowledgements

This package is a critical part of the Supabase Elixir ecosystem, enabling seamless integration with Supabase services. It plays a central role in connecting your Elixir applications to the power of Supabase.

## Additional Information

For more details on using this package and the Supabase Elixir SDK as a whole, refer to the [Supabase Elixir SDK documentation](https://hexdocs.pm/supabase_potion).
