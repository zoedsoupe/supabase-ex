# Supabase Elixir Ecosystem Update

_Supa Squad_

---

## Project Overview

I’ve been working on several Elixir libraries to integrate with the Supabase ecosystem. Here's the current state and roadmap for the following libraries:

- `supabase-ex`
- `postgrest-ex`
- `storage-ex`
- `gotrue-ex`

---

## [supabase-ex](https://github.com/zoedsoupe/supabase-ex)

- **Client Initialization** simplified
  - More user control over OTP processes
  - Improved documentation for client startup
- **HTTP Client** for Supabase APIs
  - High-level configuration options (similar to `supabase-js`)
  - Some points need refactoring

> _**Downloads:** 2422_

---

## [postgrest-ex](https://github.com/zoedsoupe/postgrest-ex)

- **Composability**: Lazy query and filter builders like `postgrest-js` and `postgrest-go`
- **Error Mapping**: Comprehensive structure
- **Ecto Integration**: Can parse PostgREST JSON responses into Ecto schemas/structs

> _**Downloads:** 242_
> _Many in the Elixir community prefer using Ecto directly for PostgreSQL_

---

## [storage-ex](https://github.com/zoedsoupe/storage-ex)

- **Bucket Operations**: Full CRUD
- **Object Operations**: Stream uploads/downloads supported
  - Added streaming support for large files

> _**Downloads:** 802_
> _There was a broken version on Hex for some time 😕_

---

## [gotrue-ex](https://github.com/zoedsoupe/gotrue-ex)

- **Plug Support**: Middleware integration
- **Phoenix.LiveView Hooks**: Out-of-the-box support
- **Full User Management**: Sign up, password reset, email invitation, and admin APIs
- **Auth Methods**: OAuth, OTP, email/password, ID token, SSO, etc.
- **Anonymous Sign In**

> _**Downloads:** 1738_

---

## Roadmap & Future Work

### Upcoming Features
- **Supabase.UI** for `Phoenix.LiveView`
- **Supabase Realtime Integration**
  - Discussing adapters for `PubSub` and process messaging with @filipecabaco
- **PKCE Flow Improvements** in `gotrue-ex`
- **Ecto Integration** in `postgrest-ex`
  - Enhance `Ecto.Query` support

---

## Closing

Thank you for your attention! 🎉

Let’s keep building the Supabase ecosystem stronger together! 🚀

Find my work at:  
[GitHub](https://github.com/zoedsoupe) | [Hex](https://hex.pm/users/zoedsoupe)
