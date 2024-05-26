---
title: Supabase e Phoenix LiveView - o match perfeito
author: zoedsoupe <zoey.spessanha@zeetech.io>
theme:
  name: catppuccin-frappe
---

Sobre mim
---

![Zoey Pessanha](../assets/profile_250.png)

Olá! Eu sou a Zoey, uma entusiasta de `Elixir`, Engenheira de Software e também apaixonada por programação funcional e desenvolvimento web.

Além disso, eu uso NixOS (atualmente, `nix-darwin`)

## Fun facts

- Sou travesty 🏳️‍⚧️
- Eu adoro cozinhar
- Gosto de alguns animes estranhos (como Serial Experiments Lain)
- Também gosto de viajar

<!-- end_slide -->

Supabase: Backend as a Service (BaaS)
---

## O que é Supabase?

**Supabase** é uma plataforma de backend como serviço, totalmente open source, que fornece ferramentas para desenvolvimento simplificado de aplicações web.

## Soluções oferecidas pela Supabase

<!-- column_layout: [3, 3] -->

<!-- column: 0 -->

### PostgreSQL gerenciado

Gerenciamento da base de dados com backups, migrações versionadas e extensões.

### Autenticação

Gerenciamento de pessoas usuárias e login via redes sociais.

### Armazenamento

Permite uploads e downloads de arquivos, com interface S3.

<!-- column: 1 -->

### Realtime

Eventos de mudanças no banco de dados, broadcast de mensagens e detecção de presença.

### Funções

Permite executar funções serverless.

<!-- end_slide -->

Supabase usa Elixir!
---

Existem 2 projetos que são implementados com Elixir na codebase:

1. `Supavisor` - A cloud-native, multi-tenant Postgres connection pooler.
2. `Realtime` - Broadcast, Presence, and Postgres Changes via WebSockets.

<!-- end_slide -->

Por que outra biblioteca Supabase para Elixir?
---

Existem 3 bibliotecas "oficiais" para interagir com os serviços da Supabase em Elixir:
1. `supabase` - https://github.com/treebee/supabase-elixir
2. `gotrue-elixir` - https://github.com/supabase-community/gotrue-ex
3. `postgrest-ex` - https://github.com/supabase-community/postgrest-ex

## O Problema

No entanto, existem alguns pontos negativos:
- Pacotes parecem não ser mantidos/não têm mais atualizações
- Pacotes estão divididos em diferentes lugares/proprietários
- Pacotes não parecem ter uma boa integração entre si
- Pacotes não aproveitam as vantagens do Erlang/OTP
- Faltam bibliotecas para realtime e UI (Phoenix Live View)
- `postgrest-ex` não se integra diretamente com `Ecto`

## A Ideia

- Criar uma biblioteca que unifique todas as integração
- Permitir o uso de integrações separadamente
- Implementar integrações faltantes (realtime e UI)
- Integrar PostgREST com `Ecto`
- Disponibilizar uma API pública de alto nível
- Integrar Supabase Auth com aplicações Plug e Live View

> Phoenix Live View está crescendo rapidamente como uma alternativa para desenvolvimento web full stack, então seria bom ter mais bibliotecas de UI

<!-- end_slide -->

Solução: Supabase Potion
---


## Código Fonte

- Supabase Potion: https://github.com/zoedsoupe/supabase-ex
- Supabase Storage: https://github.com/zoedsoupe/storage-ex
- Supabase PostgREST: https://github.com/zoedsoupe/postgrest-ex
- Supabase Auth (GoTrue): https://github.com/zoedsoupe/gotrue-ex

## Pontos Fortes

- Centraliza as integrações numa única interface
- Provém uma API de alto nível Plug and Play
- Se aproveitas das vantagens do Erlang/OTP

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

## Como funciona?

```elixir
# mix.exs
defmodule MyApp.MixProject do
  defp deps do
    [
      # ...
      {:supabase_potion, "~> 0.3"},
      {:supabase_gotrue, "~> 0.3"}
      # ...
    ]
  end
end
```

<!-- column: 1-->

```elixir
# config.exs ou runtime.exs
import Config

config :supabase_potion,
  manage_clients?: true,
  supabase_base_url: "https://<app>.supabase.io",
  supabase_api_key: "your-super-secret-api-key"
```

Depois disso, você pode iniciar alguns clientes:

```elixir
Supabase.init_client(MyClient)
{:ok, #PID<0.123.0>}
```

<!-- end_slide -->

Solução: Supabase Potion
---

![](../assets/supabase_potion_arch.png)


<!-- end_slide -->

Como é definido e como usar?
---

Um `Supabase.Client` é definido como:

```elixir
# campos com valores sensíveis são filtrados quando inspecionados
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

<!-- end_slide -->

O que já está implementado?
---

## Clientes Supabase

A aplicação principal que define:
- Gerenciamento interno de múltiplos clientes
- Estrutura para configurar um cliente com diferentes opções
- Base de código extensível para outras integrações consumirem

## Supabase Storage

- Gerenciamento de buckets
- Gerenciamento de Objetos

## Supabase PostgREST

- Implementação completa da API de linguagem de consulta para quem não quiser usar DSLs do `Ecto`

## Supabase Auth

- Gerenciamento de múltiplos métodos de autenticação
- Plugs/hooks para aplicações baseadas em Plug (como Phoenix) e Live View para autenticação

<!-- end_slide -->

Próximos passos
---

## Supabase UI

- Componentes funcionais e Live para Live View
- Regras de design e helpers para construir interfaces web facilmente com Supabase UI

## Supabase Realtime

- Integração básica via API
- Integrar com Phoenix.PubSub

<!-- end_slide -->

Exemplos de uso: Login com link mágico
---

```elixir
defmodule MyAppWeb.SessionController do
  use MyAppWeb, :controller

  alias Supabase.GoTrue

  def create(conn, %{"email" => email}) do
    GoTrue.sign_in_with_otp(MyClient, %{
      email: email,
      options: %{
        email_redirect_to: ~p"/session/confirm",
        should_create_user: false
      }
    })

    conn
  end

  def confirm(conn, %{"type" => "email", "token_hash" => _} = params) do
    case GoTrue.verify_token(params) do
      {:ok, session} ->
        conn
        |> GoTrue.Plug.put_token_in_session(session)
        |> redirect(to: ~p"/super-secret")

      {:error, %{"error_code" => "otp_expired"}} -> # ...

      {:error, _} -> # ...
    end
  end
end
```

<!-- end_slide -->

Exemplo de uso: Streaming de download de um Objeto
---

```elixir
defmodule MyApp.FileStorage do
  alias Supabase.Storage

  @wildcard "path/to/object.txt"
  @output_file "path/to/transformed_object.txt"

  def transform_and_save_object do
    case Storage.download_object_lazy(MyClient, "my-bucket", @wildcard) do
      {:ok, stream} ->
        stream
        |> Stream.map(&String.upcase/1)
        |> Stream.into(File.stream!(@output_file))
        |> Stream.run()

        IO.puts("File transformed and saved successfully!")

      {:error, reason} ->
        IO.puts("Failed to download object: #{reason}")
    end
  end
end
```

<!-- end_slide -->

Exemplo de uso: CRUD usando PostgREST
---

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

```elixir
defmodule MyApp.Avatar do
  use Ecto.Schema
  import Ecto.Changeset
  alias Supabase.PostgREST, as: Q

  @derive Jason.Encoder
  embeeded_schema do
    field :url, :string
    field :inserted_at, :utc_datetime

    belongs_to :user, Supabase.GoTrue.User
  end

  def changeset(avatar \\ %Avatar{}, params) do
    # ...
  end

  def create(params) do
    changes = changeset(params)
    result = apply_action(changes, :insert)

    with {:ok, avatar} <- result do
      Q.from("avatars")
      |> Q.insert(avatar, returning: true)
      |> Q.execute_to(__MODULE__)
    end
  end
end
```

<!-- column: 1 -->

```elixir
defmodule MyApp.Avatar do
  # ...

  def find_by_id(id) do
    Q.from("avatars")
    |> Q.select(:*, returning: true)
    |> Q.eq(:id, id)
    |> Q.single()
    |> Q.execute_to(__MODULE__)
  end

  def list_by_user_id(user_id) do
    after_may_first = ~N[2024-05-01 00:00:00]

    Q.from("avatars")
    |> Q.select(:*, returning: true)
    |> Q.eq(:user_id, user_id)
    |> Q.gte(:inserted_at, after_may_first)
    |> Q.execute_to(__MODULE__)
  end

  def delete(id) do
    Q.from("avatars")
    |> Q.eq(:id, id)
    |> Q.delete()
    |> Q.execute_to(__MODULE__)
  end
end
```

<!-- end_slide -->

Finalizando!
---

<!-- column_layout: [1, 3, 1] -->

<!-- column: 1 -->
![That's all folks](../assets/thats_all_folks.jpg)

<!-- end_slide -->

Contato
---

![](../assets/linktree_qrcode.png)

<!-- reset_layout -->
