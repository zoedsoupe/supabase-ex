VERSION 0.7

deps:
  ARG ELIXIR=1.15.4
  FROM hexpm/elixir:${ELIXIR}-alpine
  WORKDIR /src
  COPY mix.exs mix.lock ./
  COPY --dir apps . # check .earthlyignore
  RUN mix local.rebar --force
  RUN mix local.hex --force
  RUN mix deps.get
  SAVE ARTIFACT /src/deps AS LOCAL deps

ci:
  FROM +deps
  COPY .credo.exs .
  COPY .formatter.exs .
  RUN mix clean
  RUN mix compile --warning-as-errors
  RUN mix format --check-formatted
  RUN mix credo --strict

test:
 BUILD +unit-test

unit-test:
  FROM +deps
  RUN MIX_ENV=test mix deps.compile
  COPY mix.exs mix.lock ./
  COPY .env-sample ./
  COPY --dir config ./
  COPY --dir apps ./
