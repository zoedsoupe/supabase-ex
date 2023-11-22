import Config

config :supabase,
  supabase_base_url: System.fetch_env!("SUPABASE_URL"),
  supabase_api_key: System.fetch_env!("SUPABASE_KEY")

try do
  import_config "#{config_env()}.exs"
rescue
  _ -> nil
end
