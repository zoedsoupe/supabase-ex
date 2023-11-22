defmodule Supabase.GoTrue.Schemas.SignInWithOauth do
  @moduledoc false

  use Supabase, :schema

  alias Supabase.GoTrue.User.Identity

  @type t :: %__MODULE__{
          provider: Identity.providers(),
          options: %__MODULE__.Options{
            redirect_to: String.t() | nil,
            scopes: list(String.t()) | nil,
            query_params: map,
            skip_browser_redirect: boolean
          }
        }

  @primary_key false
  embedded_schema do
    field(:provider, Ecto.Enum, values: Identity.providers())

    embeds_one :options, Options, primary_key: false do
      field(:redirect_to, :string)
      field(:scopes, {:array, :string})
      field(:query_params, :map, default: %{})
      field(:skip_browser_redirect, :boolean)
    end
  end

  def options_to_query(%__MODULE__{options: options, provider: provider}) do
    query_params = Map.get(options, :query_params, %{})
    query = Map.take(options, [:redirect_to, :scopes])

    query
    |> Map.update!(:scopes, &join_scopes/1)
    |> Map.put(:provider, provider)
    |> Map.merge(query_params)
  end

  defp join_scopes(nil), do: nil

  defp join_scopes(scopes) when is_list(scopes) do
    Enum.join(scopes, " ")
  end

  def parse(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:provider])
    |> validate_required([:provider])
    |> cast_embed(:options, with: &options_changeset/2, required: false)
    |> maybe_put_default_options()
    |> apply_action(:parse)
  end

  defp maybe_put_default_options(%{valid?: false} = c), do: c

  defp maybe_put_default_options(changeset) do
    if get_embed(changeset, :options) do
      changeset
    else
      put_embed(changeset, :options, %__MODULE__.Options{})
    end
  end

  defp options_changeset(options, attrs) do
    options
    |> cast(attrs, ~w[redirect_to scopes query_params skip_browser_redirect]a)
    |> parse_uri()
  end

  defp parse_uri(%{valid?: false} = c), do: c

  defp parse_uri(changeset) do
    redirect_to = get_change(changeset, :redirect_to)

    if redirect_to do
      case URI.new(redirect_to) do
        {:ok, uri} -> put_change(changeset, :redirect_to, uri)
        {:error, reason} -> add_error(changeset, :redirect_to, "Invalid URI: #{reason}")
      end
    else
      changeset
    end
  end
end
