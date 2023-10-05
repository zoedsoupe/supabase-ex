# Supabase Potion

> Complete SDK and APIs integrations with Supabase

This monorepo houses the collection of Elixir SDK packages for integrating with Supabase, the open-source Firebase alternative. Our goal is to offer developers a seamless integration experience with Supabase services using Elixir.

## Packages Overview

- **Supabase**: Main entrypoint for the Supabase SDK library, providing easy management for Supabase clients and connections. [Guide](#usage).
- **Supabase Storage**: Offers developers a way to store large objects like images, videos, and other files. [Guide](./guides/storage.md)
- **Supabase PostgREST**: Directly turns your PostgreSQL database into a RESTful API using PostgREST. [Guide](#)
- **Supabase Realtime**: Provides a realtime websocket API, enabling listening to database changes. [Guide](#)
- **Supabase Auth**: A comprehensive user authentication system, complete with email sign-in, password recovery, session management, and more. [Guide](#)
- **Supabase UI**: UI components to help build Supabase-powered applications quickly. [Guide](#)
- **Supabase Fetcher**: Customized HTTP client for making requests to Supabase APIs. [Guide](./guides/fetcher.md)

## Getting Started

### Installation

To install the complete SDK:

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.2"}
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

## Configuration

Ensure your Supabase configurations are set:

```elixir
import Config

config :supabase,
  manage_clients?: true,
  supabase_url: System.fetch_env!("SUPABASE_BASE_URL"),
  supabase_key: System.fetch_env!("SUPABASE_API_KEY"),
```

Make sure to set the environment variables `SUPABASE_BASE_URL` and `SUPABASE_API_KEY`.

Detailed information on locating your Supabase base URL and API key can be found in the `Supabase.MissingSupabaseConfig` module.

## General Roadmap

If you want to track integration-specific roadmaps, check their own README.

- [x] Fetcher to interact with the Supabase API in a low-level way
- [x] Supabase Storage integration
- [ ] Supabase UI for Phoenix Live View
- [ ] Supabase Postgrest integration
- [ ] Supabase Auth integration
- [ ] Supabase Realtime API integration


## Why another Supabase package?

Well, I tried to to use the [supabase-elixir](https://github.com/treebee/supabase-elixir) package but I had some strange behaviour and it didn't match some requirements of my project. So I started to search about Elixir-Supabase integrations and found some old, non-maintained packages that doesn't match some Elixir "idioms" and don't leverage the BEAM for a more integrated experience.

Also I would like to contribute to OSS in some way and gain more experience with the BEAM and HTTP integrations too. So feel free to not to use, give some counter arguments and also contribute to these packages!

## Credits & Inspirations

- [supabase-elixir](https://github.com/treebee/supabase-elixir)
- [storage-js](https://github.com/supabase/storage-js)

## Contributing

Contributions, issues, and feature requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgements

This SDK is a comprehensive representation of Supabase's client integrations. Thanks to the Supabase community for their support and collaboration.

## License

[MIT](LICENSE)

---

With the Supabase Elixir SDK, you have the tools you need to supercharge your Elixir applications by seamlessly integrating them with Supabase's powerful cloud services. Happy coding! 😄
