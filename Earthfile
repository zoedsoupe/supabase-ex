VERSION 0.7

ARG MIX_ENV=test

deps:
  ARG ELIXIR=1.15.7
  ARG OTP=26.1.2
  FROM hexpm/elixir:${ELIXIR}-erlang-${OTP}-alpine-3.17.5
  RUN apk add --no-cache build-base
  WORKDIR /src
  RUN mix local.rebar --force
  RUN mix local.hex --force
  COPY mix.exs mix.lock ./
  COPY --dir lib . # check .earthlyignore
  RUN mix deps.get
  RUN mix deps.compile --force
  RUN mix compile
  SAVE ARTIFACT /src/_build AS LOCAL _build
  SAVE ARTIFACT /src/deps AS LOCAL deps

ci:
  FROM +deps
  COPY .formatter.exs .
  RUN mix clean
  RUN mix compile --warning-as-errors
  RUN mix format --check-formatted
  RUN mix credo --strict

test:
  FROM +deps
  COPY mix.exs mix.lock ./
  COPY --dir lib ./
  RUN mix test
