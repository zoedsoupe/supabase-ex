import Config

config :supabase_potion,
  supabase_base_url: System.fetch_env!("SUPABASE_URL"),
  supabase_api_key: System.fetch_env!("SUPABASE_KEY")

import_config "#{config_env()}.exs"
