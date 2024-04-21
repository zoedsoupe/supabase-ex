import Config

if config_env() == :dev do
  config :supabase_potion,
    manage_clients: true,
    supabase_base_url: System.get_env("SUPABASE_URL"),
    supabase_api_key: System.get_env("SUPABASE_KEY")
end
