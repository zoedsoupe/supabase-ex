# Supabase Potion

![Supabase Logo](https://supabase.io/img/supabase-logo.svg)

The Supabase Elixir SDK is a powerful library that enables seamless integration with [Supabase](https://supabase.io/), a cloud-based platform that provides a suite of tools and services for building modern web and mobile applications. This SDK allows you to interact with various Supabase services, such as storage, authentication, and realtime functionality, directly from your Elixir application.

## Installation

To get started with the Supabase Elixir SDK, you need to add it to your Elixir project's dependencies. Open your `mix.exs` file and add the following line to the `deps` function:

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.1"}
  ]
end
```

After adding the dependency, run `mix deps.get` to fetch and install the SDK.

## Usage

The Supabase Elixir SDK provides a flexible way to manage `Supabase.Client` instances, which can, in turn, manage multiple `Supabase.Connection` instances. Here's a brief overview of the key concepts:

- **Supabase.Client**: This represents a container for multiple connections and holds general information about your Supabase setup. It can be used to interact with various Supabase services.

- **Supabase.Connection**: A connection holds information about the connection to the Supabase API, including the base URL, API key, and access token. Each connection can be associated with a specific bucket for performing operations.

### Starting a Connection

To start a new connection, you can use the `Supabase.Connection.start_link/1` function. For example:

```elixir
iex> Supabase.Connection.start_link(name: :my_conn, conn_info: %{base_url: "https://myapp.supabase.io", api_key: "my_api_key"})
{:ok, #PID<0.123.0>}
```

Alternatively, you can use the higher-level API provided by the `Supabase` module, using the `Supabase.init_connection/1` function:

```elixir
iex> Supabase.init_connection(%{base_url: "https://myapp.supabase.io", api_key: "my_api_key", name: :my_conn, alias: :conn1})
{:ok, #PID<0.123.0>}
```

### Starting a Client

After starting one or more connections, you can start a client using the `Supabase.Client.start_link/1` function. However, it's recommended to use `Supabase.init_client/2`, which allows you to pass client options and a list of connections that the client will manage. For example:

```elixir
iex> Supabase.Client.init_client(%{db: %{schema: "public"}}, conn_list)
{:ok, #PID<0.123.0>}
```

## Acknowledgements

This SDK package represents the complete SDK for Supabase, encompassing all the functionality of various Supabase client integrations, including:

- [supabase-storage](https://hex.pm/packages/supabase_storage)
- [supabase-postgrest](https://hex.pm/packages/supabase_postgrest)
- [supabase-realtime](https://hex.pm/packages/supabase_realtime)
- [supabase-auth](https://hex.pm/packages/supabase_auth)
- [supabase-ui](https://hex.pm/packages/supabase_ui)
- [supabase-fetcher](https://hex.pm/packages/supabase_fetcher)

You can choose to install only specific packages if you don't need the complete functionality. Just add the desired packages to your `deps` list in the `mix.exs` file.

For more detailed documentation, refer to the [supabase_connection documentation](https://hexdocs.pm/supabase_connection).

## Supabase Services

The Supabase Elixir SDK allows you to interact with various Supabase services:

### Supabase Storage

Supabase Storage is a service for storing large objects like images, videos, and other files. It provides a simple API with strong consistency, similar to AWS S3.

### Supabase PostgREST

PostgREST is a web server that turns your PostgreSQL database into a RESTful API. It automatically generates API endpoints and operations based on your database's structure and permissions.

### Supabase Realtime

Supabase Realtime offers a realtime WebSocket API powered by PostgreSQL notifications. You can use it to listen to changes in your database and receive updates instantly as they happen.

### Supabase Auth

Supabase Auth is a comprehensive user authentication system that includes features like email and password sign-in, email verification, password recovery, session management, and more, out of the box.

### Supabase UI

Supabase UI provides a set of UI components to help you build Supabase-powered applications quickly. It's built on top of Tailwind CSS and Headless UI, and it's fully customizable. The package even includes `Phoenix.LiveView` components!

### Supabase Fetcher

Supabase Fetcher is a customized HTTP client for Supabase, mainly used in Supabase Potion. It gives you complete control over how you make requests to any Supabase API.

---

With the Supabase Elixir SDK, you have the tools you need to supercharge your Elixir applications by seamlessly integrating them with Supabase's powerful cloud services. Happy coding! 😄
