defmodule Supabase.MissingSupabaseConfig do
  defexception [:message]

  @impl true
  def exception(config) do
    message = """
    Missing #{if config == :key, do: "API Key", else: "Base URL"} configuration for Supabase.Fetch
    Please ensure or add the following to your config/runtime.exs file:

        import Config

        config :supabase,
          supabase_url: System.fetch_env!("SUPABASE_BASE_URL"),
          supabase_key: System.fetch_env!("SUPABASE_API_KEY"),

    Remember to set the environment variables SUPABASE_BASE_URL and SUPABASE_API_KEY
    if you choose this option. Otherwise you can pass the values directly to the config file.

    Alternatively you can pass the values directly to the `Supabase.Client.init_client!/1` function:

        iex> Supabase.init_client!(%{
              conn: %{
                base_url: System.fetch_env!("SUPABASE_BASE_URL"),
                api_key: System.fetch_env!("SUPABASE_API_KEY")
              }
            })

    #{if config == :key, do: missing_key_config_walktrough(), else: missing_url_config_walktrough()}
    """

    %__MODULE__{message: message}
  end

  defp missing_url_config_walktrough do
    """
    You can find your Supabase base URL in the Settings page of your project.
    Firstly select your project from the initial Dashboard.
    On the left sidebar, click on the Settings icon, then select API.
    The base URL is the first field on the page.
    """
  end

  defp missing_key_config_walktrough do
    """
    You can find your Supabase API key in the Settings page of your project.
    Firstly select your project from the initial Dashboard.
    On the left sidebar, click on the Settings icon, then select API.
    The API key is the second field on the page.

    There two types of API keys, the public and the private. The last one
    bypass any Row Level Security (RLS) rules you have set up.
    So you shouldn't use it in your frontend application.

    If you don't know what RLS is, you can read more about it here:
    https://supabase.com/docs/guides/auth/row-level-security

    For most cases you should prefer to use the public "anon" Key.
    """
  end
end
