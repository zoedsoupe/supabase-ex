# Supabase Fetcher

The **Supabase Fetcher** is a versatile HTTP client that serves as an entry point for interacting with Supabase APIs from your Elixir applications. While it's often recommended to use higher-level APIs for specific Supabase services like [supabase-storage](https://github.com/zoedsoupe/supabase/tree/main/apps/supabase_storage) or the all-in-one package [supabase-potion](https://github.com/zoedsoupe/supabase), this SDK provides low-level capabilities for fine-grained control and customization.

## Overview

This SDK allows you to make HTTP requests to Supabase and handle responses efficiently. It comes with several functions for common HTTP operations, such as GET, POST, PUT, DELETE, and file uploads.

## Usage

### Basic Request

TODO

### Streaming Large Files

You can use `Supabase.Fetcher.stream/3` to make a GET request to a URL and stream back the response. This function is especially useful for streaming large file downloads. Custom `Finch` options can also be passed for more control over the request.

```elixir
iex> {status, stream} = Supabase.Fetcher.stream("https://example.com")
iex> file = File.stream!("path/to/file", [], 4096)
Stream.run Stream.into(stream, file)
```

```elixir
iex> headers = [{"authorization", "<supabase-key>"}]
iex> Supabase.Fetcher.stram("<url>", headers, opts) # opts are passed directly to Finch.stream/5
```

### Making HTTP Requests

The SDK provides convenient functions for making common HTTP requests:

- `Supabase.Fetcher.get/2`: Perform a GET request.
- `Supabase.Fetcher.post/3`: Perform a POST request.
- `Supabase.Fetcher.put/3`: Perform a PUT request.
- `Supabase.Fetcher.delete/3`: Perform a DELETE request.

These functions format the response to a map or retrieve the error reason as a `String.t()`.

### Uploading Files

You can use `Supabase.Fetcher.upload/4` to upload a binary file to a URL using either a POST or PUT request. This is useful for file uploads in your applications.

```elixir
iex> Supabase.Fetcher.upload(:post, "https://example.com/upload", "path/to/file")
```

### Headers and Authentication

The SDK supports adding custom headers to requests. Additionally, you can use `Supabase.Fetcher.apply_headers/2` to conveniently set headers for authentication. It automatically includes the API key and, optionally, a token in the headers.

```elixir
iex> headers = Supabase.Fetcher.apply_headers("apikey-value")
iex> Supabase.Fetcher.get("https://example.com", headers)
```

## Acknowledgements

While the Supabase Fetcher Elixir SDK offers low-level control for making HTTP requests to Supabase, it is part of the broader Supabase ecosystem, which includes higher-level libraries for various Supabase services.

## Additional Information

For more details on using this package, refer to the [Supabase Fetcher documentation](https://hexdocs.pm/supabase_fetcher).
