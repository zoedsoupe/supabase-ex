# Supabase Potion

Where the magic starts!

## Getting Started

### Installation

To install the base SDK:

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.4"}
  ]
end
```

### General usage

This library per si is the base foundation to user Supabase services from Elixir, so to integrate with specific services you need to add each client library you want to use.

Available client services are:
- [PostgREST](https://github.com/zoedsoupe/postgres-ex)
- [Storage](https://github.com/zoedsoupe/storage-ex)
- [Auth/GoTrue](https://github.com/zoedsoupe/gotrue-ex)

So if you wanna use the Storage and Auth/GoTrue services, your `mix.exs` should look like that:

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.4"}, # base SDK
    {:supabase_storage, "~> 0.3"}, # storage integration
    {:supabase_gotrue, "~> 0.3"}, # auth integration
  ]
end
```

### Clients

A `Supabase.Client` holds general information about Supabase, that can be used to intereact with any of the children integrations, for example: `Supabase.Storage` or `Supabase.UI`.

`Supabase.Client` is defined as:

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

## Configuration

Ensure your Supabase configurations are set:

```elixir
import Config

config :supabase,
  supabase_base_url: System.fetch_env!("SUPABASE_BASE_URL"),
  supabase_api_key: System.fetch_env!("SUPABASE_API_KEY"),
```

- `supabase_base_url`: The base URL of your Supabase project! More information on how to find it can be seen on the [next section](#how-to-find-my-supabase-base-url?)
- `supabase_api_key`: The secret of your Supabase project! More information on how to find it can be seen on the [next section](#how-to-find-my-supabase-api-key?)

Make sure to set the environment variables `SUPABASE_BASE_URL` and `SUPABASE_API_KEY`.

## Starting a Client

You can start a client using the `Supabase.init_client/1` or `Supabase.init_client!/1` function.

```elixir
iex> Supabase.init_client!(%{conn: %{base_url: "<supa-url>", api_key: "<supa-key>"}})
{:ok, %Supabase.Client{}}
```

> Note that if you already set up supabase potion options on your application config, you can safely use `Supabase.init_client/0` or `Supabase.init_client!/0`

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
