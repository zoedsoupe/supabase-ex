defmodule Supabase.FetcherBehaviour do
  @moduledoc "Defines Supabase HTTP Clients callbacks"

  @typep nullable(a) :: a | nil

  @type url :: String.t() | URI.t()
  @type body :: nullable(map) | map
  @type headers :: [{String.t(), String.t()}]
  @type response :: map | String.t()
  @type reason :: String.t() | atom
  @type method :: :get | :post
  @type result :: {:ok, response} | {:error, reason}

  @callback get(url, body, headers, opts) :: result
            when opts: [resolve_json: boolean]
  @callback post(url, body, headers) :: result
  @callback put(url, body, headers) :: result
  @callback head(url, body, headers) :: result
  @callback patch(url, body, headers) :: result
  @callback delete(url, body, headers) :: result
  @callback upload(method, url, Path.t(), headers) :: result
  @callback stream(url, headers, keyword) :: {:ok, stream} | {:error, reason}
            when stream: Enumerable.t()
end
