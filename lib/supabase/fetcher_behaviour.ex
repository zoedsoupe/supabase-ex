defmodule Supabase.FetcherBehaviour do
  @moduledoc "Defines Supabase HTTP Clients callbacks"

  @typep nullable(a) :: a | nil

  @type url :: String.t() | URI.t()
  @type body :: nullable(map) | map
  @type headers :: [{String.t(), String.t()}]
  @type opts :: [resolve_json: boolean] | []
  @type response :: map | String.t()
  @type reason :: String.t() | atom
  @type method :: :get | :post
  @type result :: {:ok, response} | {:error, reason}

  @callback get(url, body, headers, opts) :: result
  @callback post(url, body, headers, opts) :: result
  @callback put(url, body, headers, opts) :: result
  @callback head(url, body, headers, opts) :: result
  @callback patch(url, body, headers, opts) :: result
  @callback delete(url, body, headers, opts) :: result
  @callback upload(method, url, Path.t(), headers) :: result
  @callback stream(url, headers, keyword) :: {:ok, stream} | {:error, reason}
            when stream: Enumerable.t()
end
