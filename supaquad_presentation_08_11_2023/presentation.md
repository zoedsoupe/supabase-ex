---
title: Elixir's new Supabase Client
author: zoedsoupe <zoey.spessanha@zeetech.io>
---

About me
---

![Zoey Pessanha](./assets/profile.png)

Hi there! I'm Zoey, an `Elixir` enthusiast, Software Engineer and also passionated with functional programming and web development.
I really like to contribute to the `Elixir` ecosystem and I admire Supabase's effort to support it too.

btw, I use NixOS (actually, `nix-darwin`)

## Experiences

<!-- column_layout: [1, 1, 1, 1, 1] -->

<!-- column: 0 -->
![Cumbuca's logo](./assets/logo_cumbuca.png)

<!-- column: 1 -->
![Nubank's logo](./assets/logo_nubank.jpeg)

<!-- column: 2 -->
![Sófácil's logo](./assets/logo_solfacil.jpeg)

<!-- column: 3 -->
![Pescarte's logo](./assets/logo_pescarte.png)

<!-- column: 4 -->
![Elixir em Foco's logo](./assets/logo_elixiremfoco.png)

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

- [Supabase Potion](https://github.com/zoedsoupe/supabase)
- [Supabase Storage](https://github.com/zoedsoupe/supabase_storage)
- [Supabase PostgREST](https://github.com/zoedsoupe/supabase_postgrest)

## Strengths

- leverage `DynamicSupervisors` and `Registry`
- implements a common used `Fecther` to low-level interaction to Supabase's APIs
- implements structs for Supabase's entities like `Bucket` for Storage API, for example
- it aims to be highly configurable
- it can manage thousands of different clients

## How it works?

Firstly, you need to set basic config for the client in your `config.exs` or `runtime.exs`:

```elixir
import Config

config :supabase,
  base_url: {:system, "SUPABASE_URL"},
  api_key: {:system, "SUPABASE_KEY"}
```
After that you need to start some clients:

```elixir
Supabase.init_client(%{name: MyClient})
{:ok, #PID<0.123.0>}
```

## Starting clients manually

Also, if you want to manage clients manually, you can:

1. directly calls `Supabase.Client.start_link/1`

```elixir
{:ok, #PID<0.123.0>} = Supabase.Client.start_link(params)
```

<!-- end_slide -->

Solution: Supabase Potion
---

## Starting clients manually

Firstly: manage the supervisor

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Supabase.ClientSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

and then start clients:

```elixir
Supabase.ClientSupervisor.start_child({Supabase.Client, params})
{:ok, #PID<0.123.0>}
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

## Supabase Clients

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

<!-- end_slide -->

What are coming next?
---

## Supabase PostgREST

- integration with `Ecto` via custom adapter to be able to use `Ecto.Query` easily
- complete API implementation query language if one do not want to use `Ecto` DSLs

## Supabase Auth

- managment for multiple authentication methods
  - email + password
  - oauth2
  - magic links
  - SAML/SSO
- plugs/hooks for both plug based applications (aka Phoenix) and Live View for authentication

## Supabase UI

- funciton and live components for Live View
- design rules and helpers to easily build web interfaces with Supabase UI

## Supabase Realtime

- basic integration via API
- integrate with the API, produce events as Process based message passing (or PubSub)

<!-- end_slide -->

Finish!
---

<!-- column_layout: [1, 3, 1] -->

<!-- column: 1 -->
![That's all folks](./assets/thats_all_folks.jpg)

<!-- reset_layout -->
