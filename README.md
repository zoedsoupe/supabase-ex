# Supabase Potion

> Complete SDK and APIs integrations with Supabase

This is a monorepo with all integrations.

## Installation

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.1.0"}
  ]
end
```

Notice that this would install ALL existing Supabase integrations of this project.
If you only one or two, prefer to install specific integrations, like:

```elixir
def deps do
  [
    {:supabase_storage, "~> 0.1.0"},
    {:supabase_auth, "~> 0.1.0"},
  ]
end
```

## General Roadmap

If you want to track integration-specific roadmaps, check their own README.

- [x] Fetcher to interact with the Supabase API in a low-level way
- [ ] Supabase Storage integration
- [ ] Supabase Postgrest integration
- [ ] Supabase Auth integration
- [ ] Supabase Realtime API integration

## Developing



## Why another Supabase package?

Well, I tried to to use the [supabase-elixir](https://github.com/treebee/supabase-elixir) package but I had some strange behaviour and it didn't match some requirements of my project. So I started to search about Elixir-Supabase integrations and found some old, non-maintained packages that doesn't match some Elixir "idioms" and don't leverage the BEAM for a more integrated experience.

Also I would like to contribute to OSS in some way and gain more experience with the BEAM and HTTP integrations too. So feel free to not to use, give some counter arguments and also contribute to these packages!

## Credits & Inspirations

- [supabase-elixir](https://github.com/treebee/supabase-elixir)
- [storage-js](https://github.com/supabase/storage-js)
