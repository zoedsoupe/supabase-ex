defmodule Supabase.Fetcher do
  @moduledoc """
   A fundamental HTTP client for interfacing directly with Supabase services.

  `Supabase.Fetcher` provides the groundwork for sending HTTP requests to the Supabase infrastructure. This includes utilities for various HTTP methods such as GET, POST, PUT, DELETE, and functions to simplify the process of streaming data or uploading files.

  ## Key Features

  - **Low-level HTTP Interactions**: This module allows for raw HTTP requests to any URL, simplifying interactions with web resources.
  - **Data Streaming**: Efficiently stream large data payloads, such as downloading files.
  - **Request Customization**: Extensive header customization and utility functions for constructing requests tailored to your requirements.
  - **Response Parsing**: Automatically converts JSON responses into Elixir maps and handles various response scenarios.

  ## Recommended Usage

  While `Supabase.Fetcher` is versatile and comprehensive, it operates at a very granular level. For most applications and needs, leveraging higher-level APIs that correspond to specific Supabase services is advisable:

  - [supabase-storage](https://github.com/zoedsoupe/supabase/tree/main/apps/supabase_storage)

  For those seeking a more comprehensive integration with the entirety of Supabase's offerings, the [supabase-potion](https://github.com/zoedsoupe/supabase) package is available. This package provides an all-encompassing interface, streamlining your Supabase interactions.

  ## Disclaimer

  If your aim is to directly harness this module as a low-level HTTP client, due to missing features in other packages or a desire to craft a unique Supabase integration, you can certainly do so. However, always keep in mind that `Supabase.Potion` and other Supabase-oriented packages might offer better abstractions and ease-of-use.

  Use `Supabase.Fetcher` with a clear understanding of its features and operations.
  """

  @behaviour Supabase.FetcherBehaviour

  @spec version :: String.t()
  def version do
    {:ok, vsn} = :application.get_key(:supabase, :vsn)
    List.to_string(vsn)
  end

  @spec new_connection(atom, url, body, headers) :: Finch.Request.t()
        when url: String.t() | URI.t(),
             body: binary | nil | {:stream, Stream.t()},
             headers: list(tuple)
  defp new_connection(method, url, body, headers) do
    headers = merge_headers(default_headers(), headers)
    Finch.build(method, url, headers, body)
  end

  @spec default_headers :: list(tuple)
  defp default_headers do
    [
      {"accept", "application/json"},
      {"x-client-info", "supabase-fetch-elixir/#{version()}"}
    ]
  end

  @doc """
  Makes a HTTP request to the desired URL, with default headers and
  stream back the response. Good to stream large files downlaods.

  You can also pass custom `Finch` options directly to the underlying `Finch.stream/4` function.
  Those options can be seen on the [Finch documentation](https://hexdocs.pm/finch/Finch.html#stream/5-options).

  ## Examples

       iex> {status, stream} = Supabase.Fetcher.stream("https://example.com")
       iex> file = File.stream!("path/to/file", [], 4096)
       Stream.run Stream.into(stream, file)
  """
  @impl true
  def stream(url, headers \\ [], opts \\ []) do
    ref = make_ref()
    task = spawn_stream_task(new_connection(:get, url, nil, headers), ref, opts)
    status = receive(do: ({:chunk, {:status, status}, ^ref} -> status))

    stream =
      Stream.resource(fn -> {ref, task} end, &receive_stream(&1), fn {_ref, task} ->
        Task.shutdown(task)
      end)

    case {status, stream} do
      {200, stream} -> {:ok, stream}
      {s, _} when s >= 400 -> {:error, :not_found}
      {s, _} when s >= 500 -> {:error, :server_error}
    end
  end

  defp spawn_stream_task(%Finch.Request{} = req, ref, opts) do
    me = self()

    Task.async(fn ->
      on_chunk = fn chunk, _acc -> send(me, {:chunk, chunk, ref}) end
      Finch.stream(req, Supabase.Finch, nil, on_chunk, opts)
      send(me, {:done, ref})
    end)
  end

  defp receive_stream({ref, _task} = payload) do
    receive do
      {:chunk, {:data, data}, ^ref} -> {[data], payload}
      {:done, ^ref} -> {:halt, payload}
    end
  end

  @doc """
  Simple GET request that format the response to a map or retrieve
  the error reason as `String.t()`.

  ## Examples

       iex> Supabase.Fetcher.get("https://example.com")
       {:ok, %{"key" => "value"}}
  """
  @impl true
  def get(url, headers \\ []) do
    :get
    |> new_connection(url, nil, headers)
    |> Finch.request(Supabase.Finch)
    |> format_response()
  end

  @doc """
  Simple POST request that format the response to a map or retrieve
  the error reason as `String.t()`.

  ## Examples

       iex> Supabase.Fetcher.post("https://example.com", %{key: "value"})
       {:ok, %{"key" => "value"}}
  """
  @impl true
  def post(url, body \\ nil, headers \\ []) do
    headers = merge_headers(headers, [{"content-type", "application/json"}])

    :post
    |> new_connection(url, Jason.encode_to_iodata!(body), headers)
    |> Finch.request(Supabase.Finch)
    |> format_response()
  end

  @doc """
  Simple PUT request that format the response to a map or retrieve
  the error reason as `String.t()`.

  ## Examples

       iex> Supabase.Fetcher.put("https://example.com", %{key: "value"})
       {:ok, %{"key" => "value"}}
  """
  @impl true
  def put(url, body, headers \\ []) do
    headers = merge_headers(headers, [{"content-type", "application/json"}])

    :put
    |> new_connection(url, Jason.encode_to_iodata!(body), headers)
    |> Finch.request(Supabase.Finch)
    |> format_response()
  end

  @doc """
  Simple DELETE request that format the response to a map or retrieve
  the error reason as `String.t()`.

  ## Examples

       iex> Supabase.Fetcher.delete("https://example.com", %{key: "value"})
       {:ok, %{"key" => "value"}}

       iex> Supabase.Fetcher.delete("https://example.com", %{key: "value"})
       {:error, :not_found}
  """
  @impl true
  def delete(url, body \\ nil, headers \\ []) do
    headers = merge_headers(headers, [{"content-type", "application/json"}])

    :delete
    |> new_connection(url, Jason.encode_to_iodata!(body), headers)
    |> Finch.request(Supabase.Finch)
    |> format_response()
  end

  @doc """
  Upload a binary to the desired URL.

  params:
  - `method`: `:put` or `:post`
  - `url`: the URL to upload the file
  - `file`: the path to the file to upload
  - `headers`: list of additional headers to append to the request

  ## Examples

       iex> Supabase.Fetcher.upload(:post, "https://example.com", "path/to/file")
       {:ok, %{"key" => "value"}}
  """
  @impl true
  def upload(method, url, file, headers \\ []) do
    body_stream = File.stream!(file, [{:read_ahead, 4096}], 1024)
    %File.Stat{size: content_length} = File.stat!(file)
    content_headers = [{"content-length", to_string(content_length)}]
    headers = merge_headers(headers, content_headers)
    conn = new_connection(method, url, {:stream, body_stream}, headers)

    conn
    |> Finch.request(Supabase.Finch)
    |> format_response()
  end

  def get_full_url(base_url, path) do
    URI.merge(base_url, path)
  end

  @doc """
  Convenience function that given a `apikey` and a optional ` token`, it will return the headers
  to be used in a request to your Supabase API.

  ## Examples

       iex> Supabase.Fetcher.apply_conn_headers("apikey-value")
       [{"apikey", "apikey-value"}, {"authorization", "Bearer apikey-value"}]

       iex> Supabase.Fetcher.apply_conn_headers("apikey-value", "token-value")
       [{"apikey", "apikey-value"}, {"authorization", "Bearer token-value"}]
  """

  def apply_headers(api_key, token \\ nil, headers \\ []) do
    conn_headers = [
      {"apikey", api_key},
      {"authorization", "Bearer #{token || api_key}"}
    ]

    merge_headers(conn_headers, headers)
  end

  defp merge_headers(some, other) do
    some
    |> Kernel.++(other)
    |> Enum.dedup_by(fn {name, _} -> name end)
  end

  defp format_response({:error, %{reason: reason}}) do
    {:error, reason}
  end

  defp format_response({:ok, %{status: 404}}) do
    {:error, :not_found}
  end

  defp format_response({:ok, %{status: s, body: body}}) when s in 200..300 do
    result =
      case Jason.decode(body) do
        {:ok, body} -> body
        {:error, _} when is_binary(body) -> body
      end

    {:ok, result}
  end

  defp format_response({:ok, %{status: s, body: body}}) when s in 400..499 do
    msg = Jason.decode!(body)["message"]

    reason =
      case msg do
        "The resource was not found" -> :not_found
        _ -> msg
      end

    {:error, reason}
  end

  defp format_response({:ok, %{status: s}}) when s >= 500 do
    {:error, :server_error}
  end
end
