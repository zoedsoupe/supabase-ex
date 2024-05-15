---
title: New features of the Elixir's Supabase Client
author: zoedsoupe <zoey.spessanha@zeetech.io>
---

About me
---

![Zoey Pessanha](../assets/profile.png)

Hi there! I'm Zoey, an `Elixir` enthusiast, Software Engineer and also passionated with functional programming and web development.
I really like to contribute to the `Elixir` ecosystem and I admire Supabase's effort to support it too.

btw, I use NixOS (actually, `nix-darwin`)

## Experiences

<!-- column_layout: [1, 1, 1, 1, 1] -->

<!-- column: 0 -->
![Cumbuca's logo](../assets/logo_cumbuca.png)

<!-- column: 1 -->
![Nubank's logo](../assets/logo_nubank.jpeg)

<!-- column: 2 -->
![Sófácil's logo](../assets/logo_solfacil.jpeg)

<!-- column: 3 -->
![Pescarte's logo](../assets/logo_pescarte.png)

<!-- column: 4 -->
![Elixir em Foco's logo](../assets/logo_elixiremfoco.png)

<!-- reset_layout -->

## Fun Zoey's Facts

- I'm really into cook
- I already said that I love to code?
- I like some weird animes (serial experiments lain)
- I'm also into on travelling

[GitHub: @zoedsoupe](https://github.com/zoedsoupe) | [LinkedIn: Zoey Pessanha](https://linkedin.com/in/zoedsoupe)

<!-- end_slide -->

Why another Elixir Supabase library?
---

There are 3 "official" Elixir libraries to interact with Supabase services:
1. `supabase` - https://github.com/treebee/supabase-elixir
2. `gotrue-elixir` - https://github.com/supabase-community/gotrue-ex
3. `postgrest-ex` - https://github.com/supabase-community/postgrest-ex

> Nice work to these folks!

## The Problem

However there're some negative points:
- packages seem to be unmaintained/have no more updates
- packages are splitted into different places/owners
- packages doesn't seem to have nice integration with each order
- packages doesn't leverages Erlang/OTP advantages
- realtime and UI (Phoenix Live View) libraries are missing
- `postgrest-ex` doesn't integrate directly with `Ecto`

## The Idea

- create a library that centralizes all integration
- allow to use integrations separetely
- implement missing integrations (realtime and UI)
- integrate PostgREST with `Ecto`
- highly uses Erlang/OTP features for low-latency/concurrency
- make a higher level public API available for library users

> Phoenix Live View is rapidly growing as an alternative to full stack web development,
> so it would be nice to have more UI libraries for it

<!-- end_slide -->

Solution: Supabase Potion
---

## Source Code

- `Supabase Potion (supabase-ex)` - https://github.com/zoedsoupe/supabase-ex
- `Supabase Storage (storage-ex)`- https://github.com/zoedsoupe/storage-ex
- `Supabase PostgREST (postgrest-ex)` - https://github.com/zoedsoupe/postgrest-ex
- `Supabase GoTrue (gotrue-ex)` - https://github.com/zoedsoupe/gotrue-ex

## Strengths

- manually can handle thousands of concurrent different clients
- have a high level API to leverage Supabase's features
- implements a common used `Fetcher` to low-level interaction to Supabase's APIs
- implements structs for Supabase's entities like `Bucket` for Storage API, for example
- it aims to be highly configurable

## How it works?

Firstly, you need to set basic config for the client in your `config.exs` or `runtime.exs`:

```elixir
import Config

config :supabase_potion,
  supabase_base_url: System.get_env("SUPABASE_URL"),
  supabase_api_key: System.get_env("SUPABASE_KEY")
```
After that you need to start some clients:

```elixir
Supabase.init_client(MyClient, additional_config)
{:ok, #PID<0.123.0>}
```


<!-- end_slide -->


How it works? Supabase GoTrue/Auth
---

Beside the usual usage of the library, like to sign in an user, create one if you're admin and some more, you can leverage the `gotrue-ex` integration with `Plug` and `Phoenix.LiveView`, which allows you to manage sessions, cookies and websocket authentication using Supabase's GoTrue methods!

To achieve that you need to add an extra config to your `config.exs` file:
```elixir
config :supabase_gotrue,
  endpoint: MyAppWeb.Endpoint,
  signed_in_path: "/secret",
  not_authenticated_path: "/login",
  authentication_client: MyClient
```

With that you can use `GoTrue.Plug` functions and `GoTrue.LiveView` hooks, like:

```elixir
defmodule MyAppWeb.Router do
  use Phoenix.Router

  import Supabase.GoTrue.Plug
  alias Supabase.GoTrue.LiveView, as: Supabase.LiveView

  pipeline :browser do
   # ...
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :require_authenticated_user]
    get "/super-secret", MyController, :show
  end

  scope "/", MyAppWeb do
    pipe_through :browser

    live_session :require_authentication,
      on_mount: [{Supabase.LiveView, :ensure_authenticated}] do
      live "/secret", MyLiveView, :show
    end
  end

end
```

<!-- end_slide -->

Solution: Supabase Potion
---

You can also create specialized clients to use on your application. For example, let
say you wan to use PostgREST and GoTrue clients. After setting up the `supabase_potion` config you can create a new file called `supabase.ex`, like:

```elixir
defmodule MyApp.Supabase do
  defmodule Auth do
    use Supabase.GoTrue, client: MyClient
  end

  defmodule PostgREST do
    use Supabase.GoTrue, client: MyClient
  end

  def start_link(_opts) do
    children = [__MODULE__.Auth, __MODULE__.PostgREST]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
```

Then you can easily use your specialized client to interact with Supabase's features, like:

```elixir
MyApp.Supabase.Auth.get_user(%Session{})
{:ok, %User{}}
```

<!-- end_slide -->

How is defined and how to use it?
---

A `Supabase.Client` is defined as:

```elixir
%Supabase.Client{
  name: MyClient,
  conn: %{
    base_url: "https://<app-name>.supabase.io",
    api_key: "<supabase-api-key>",
    access_token: "<supabase-access-token>"
  },
  db: %Supabase.Client.Db{
    schema: "public"
  },
  global: %Supabase.Client.Global{
    headers: %{}
  },
  auth: %Supabase.Client.Auth{
    auto_refresh_token: true,
    debug: false,
    detect_session_in_url: true,
    flow_type: :implicit,
    persist_session: true,
    storage: nil,
    storage_key: "sb-<host>-auth-token"
  }
}
```

After started some clients you can safely use it on any integration as:

```elixir
Supabase.Storage.list_buckets(MyClient) # can also receive the client PID
{:ok, [%Supabase.Storage.Bucket{...}, ...]}
```

<!-- end_slide -->

What are already implemented?
---

<!-- column_layout: [3, 3] -->

<!-- column: 0 -->
## Supabase Potion

The "parent" application that defines:
- internal management of multiple clients
- structure for set up a client with different options

## Supabase Storage

- buckets
  - retrieve info
  - creates one
  - list all
  - empties one
  - deletes one
- objects
  - remove one
  - move and copy one
  - retrieve one
  - list all
  - uploads one
  - downloads one to memory (eager and lazy)
  - downloads one to disk (eager and lazy)
  - create signed url

<!-- column: 1 -->

## Supabase Auth
- get user from a session
- sign in with id token
- verify OTP
- sign in with OAuth
- sign in with OTP
- sign in with SSO
- sign in with email and password
- sign up a user
- reset password for email
- update current logged-in user
- plugs/hooks for both plug based applications (aka Phoenix) and Live View for authentication

### Admin-only Features:
- sign out a user
- invite a user by email
- update a user by ID
- generate link for OTP/recovery, etc.
- create a user
- delete a user
- get user by ID
- list users with pagination

## Supabase PostgREST
- complete API implementation for those who do not want to use Ecto DSLs

<!-- reset_layout -->

<!-- end_slide -->

What are coming next?
---

## Supabase PostgREST

- integration with `Ecto` via custom adapter to be able to use `Ecto.Query` easily

## Supabase Auth

- Anonymous sign in
- Improvements on the PKCE authentication flow

## Supabase UI

- funciton and live components for Live View
- design rules and helpers to easily build web interfaces with Supabase UI

## Supabase Realtime

- basic integration via API
- integrate with the API, produce events as Process based message passing (or PubSub)

<!-- end_slide -->

Live Coding!
---

<!-- column_layout: [1, 3, 1] -->

<!-- column: 1 -->
![That's all folks](../assets/live_coding.png)

<!-- reset_layout -->

## Project
The PEA Pescarte digital platform is a social-environmental voluntary project that aims to integration fisherman communities into the rest of society based on cultural and technical formation!

I'm leadershipping the tech/engineering team that is formed by 5 developers! And we decided to use Supabase to:
- Authentication
- Managed PostgreSQL
- Storage

<!-- end_slide -->

Finish!
---

<!-- column_layout: [1, 3, 1] -->

<!-- column: 1 -->
![That's all folks](../assets/thats_all_folks.jpg)

<!-- reset_layout -->
