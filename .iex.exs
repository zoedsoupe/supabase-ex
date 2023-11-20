Supabase.init_client(%{
  name: :test,
  conn: %{
    base_url: System.fetch_env!("SUPABASE_URL"),
    api_key: System.fetch_env!("SUPABASE_KEY")
  }
})
