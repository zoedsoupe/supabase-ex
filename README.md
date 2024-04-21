# Supabase Potion

Where the magic starts!

## Getting Started

### Installation

To install the base SDK:

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.3"}
  ]
end
```

### Clients

A `Supabase.Client` is an Agent that holds general information about Supabase, that can be used to intereact with any of the children integrations, for example: `Supabase.Storage` or `Supabase.UI`.

`Supabase.Client` is defined as:

- `:name` - the name of the client, started by `start_link/1`
- `:conn` - connection information, the only required option as it is vital to the `Supabase.Client`.
    - `:base_url` - The base url of the Supabase API, it is usually in the form `https://<app-name>.supabase.io`.
    - `:api_key` - The API key used to authenticate requests to the Supabase API.
    - `:access_token` - Token with specific permissions to access the Supabase API, it is usually the same as the API key.
- `:db` - default database options
    - `:schema` - default schema to use, defaults to `"public"`
- `:global` - global options config
    - `:headers` - additional headers to use on each request
- `:auth` - authentication options
    - `:auto_refresh_token` - automatically refresh the token when it expires, defaults to `true`
    - `:debug` - enable debug mode, defaults to `false`
    - `:detect_session_in_url` - detect session in URL, defaults to `true`
    - `:flow_type` - authentication flow type, defaults to `"web"`
    - `:persist_session` - persist session, defaults to `true`
    - `:storage` - storage type
    - `:storage_key` - storage key

## Usage

The Supabase Elixir SDK provides a flexible way to manage `Supabase.Client` instances, which can, in turn, manage multiple `Supabase.Client` instances. Here's a brief overview of the key concepts:

### Starting a Client

You can start a client using the `Supabase.Client.start_link/1` function. However, it's recommended to use `Supabase.init_client!/1`, which allows you to pass client options and automatically manage `Supabase.Client` processes.

```elixir
iex> Supabase.Client.init_client!(%{conn: %{base_url: "<supa-url>", api_key: "<supa-key>"}})
{:ok, #PID<0.123.0>}
```

## Configuration

Ensure your Supabase configurations are set:

```elixir
import Config

config :supabase,
  manage_clients: false,
  supabase_base_url: System.fetch_env!("SUPABASE_BASE_URL"),
  supabase_api_key: System.fetch_env!("SUPABASE_API_KEY"),
```

- `supabase_base_url`: The base URL of your Supabase project! More information on how to find it can be seen on the [next section](#how-to-find-my-supabase-base-url?)
- `supabase_api_key`: The secret of your Supabase project! More information on how to find it can be seen on the [next section](#how-to-find-my-supabase-api-key?)
- `manage_clients`: Enable or disable the internal client management by the library. Defauls to `true`, see more on the [library supervisor documentation](https://hexdocs.pm/supabase_potion/Supabase.ClientSupervisor.html).

Make sure to set the environment variables `SUPABASE_BASE_URL` and `SUPABASE_API_KEY`.

## Manually starting Clients

If you want to manually manage Clients, firstly you need to disable the config:

```elixir
import Config
  
config :supabase_potion, manage_clients: false
```

Then you need to start the Clients managements processes, that consists on:
- `Supabase.ClientSupervisor`: a DynamicSupervisor to manage multiple Supabase clients
- `Supabase.ClientRegistry`: a Registry to easily find a Supabase client

You can start them on your application startup, often on your `MyApp.Application`:

```elixir
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # rest of your Supervisor's children...
      # is recommended to start registry **before**
      # the Supervsior
      Supabase.ClientRegistry
      Supabase.ClientSupervisor
    ]
  end

  # rest of module...
end
```

Now you can start to initialize Clients! as pointed on [Staring a Client](#starting-a-client) section.

However, maybe you can full control of your Supabase Clients, then, you can start Clients individually on your application startup, like:

```elixir
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    supabase_config = supabase_client_config()
    supabase_opts = [name: MyApp.SupabaseClient, client_info: supabase_config]

    children = [
      # rest of your Supervisor's children...
      {Supabase.Client, supabase_opts}
    ]
  end

  defp supabase_client_config do
    %{
      # you can skip the `conn` config if you already set on config.exs
      conn: %{ 
        api_key: "my-super-secret-api-key",
        base_url: "https://my-project-id.supabase.co",
        access_token: "my-scoped-access-token",
      },
      db: %{schema: "my-schema"} # default to "public",
      # global headers to be used on Supabase API requests
      global: %{headers: %{"content-type": "application/json"}},
      auth: %{
        # below are the defaults values
        auto_refresh_token: true,
        debug: false,
        detect_session_in_url: true,
        flow_type: :implicit,
        persist_session: true,
        storage: "my-storage",
        storage_key: "my-storage-key"
      }
    }
  end

  # rest of module...
end
```

#### TODO

### How to find my Supabase base URL?

You can find your Supabase base URL in the Settings page of your project.
Firstly select your project from the initial Dashboard.
On the left sidebar, click on the Settings icon, then select API.
The base URL is the first field on the page.

### How to find my Supabase API Key?

You can find your Supabase API key in the Settings page of your project.
Firstly select your project from the initial Dashboard.
On the left sidebar, click on the Settings icon, then select API.
The API key is the second field on the page.

There two types of API keys, the public and the private. The last one
bypass any Row Level Security (RLS) rules you have set up.
So you shouldn't use it in your frontend application.

If you don't know what RLS is, you can read more about it here:
https://supabase.com/docs/guides/auth/row-level-security

For most cases you should prefer to use the public "anon" Key.
