# Supabase Storage

[Storage]() implementation for the `supabase_potion` SDK in Elixir.

## Installation

```elixir
def deps do
  [
    {:supabase_potion, "~> 0.2"},
    {:supabase_storage, "~> 0.2"}
  ]
end
```

## Usage

Firstly you need to initialize your Supabase client(s) as can be found on the [supabase_potion documentation]():

```elixir
iex> Supabase.init_client(%{name: Conn, conn: %{base_url: "<supa-url>", api_key: "<supa-key>"}})
{:ok, #PID<>}
```

Now you can pass the Client to the `Supabase.Storage` functions as a `PID` or the name that was registered on the client initialization:

```elixir
iex> Supabase.Storage.list_buckets(pid | client_name)  
```
