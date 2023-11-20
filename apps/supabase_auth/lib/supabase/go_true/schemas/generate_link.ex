defmodule Supabase.GoTrue.Schemas.GenerateLink do
  @moduledoc false

  import Ecto.Changeset

  @types ~w[signup invite magicLink recovery email_change_current email_change_new]a

  @options_types %{data: :map, redirect_to: :string}

  @base_types %{
    email: :string,
    type: Ecto.ParameterizedType.init(Ecto.Enum, values: @types)
  }

  @properties_types %{
    action_link: :string,
    email_otp: :string,
    hashed_token: :string,
    redirect_to: :string,
    verification_type: Ecto.ParameterizedType.init(Ecto.Enum, values: @types)
  }

  def properties(attrs) do
    {%{}, @properties_types}
    |> cast(attrs, Map.keys(@properties_types))
    |> validate_required(Map.keys(@properties_types))
    |> apply_action(:parse)
  end

  def parse(attrs) do
    [
      &sign_up_params/1,
      &invite_or_magic_link_params/1,
      &recovery_params/1,
      &email_change_params/1
    ]
    |> Enum.reduce_while(nil, fn schema, _ ->
      case result = schema.(attrs) do
        {:ok, _} -> {:halt, result}
        {:error, _} -> {:cont, result}
      end
    end)
  end

  def sign_up_params(attrs) do
    types = with_options(%{password: :string})

    {%{}, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required([:email, :password, :type])
    |> validate_redirect_to()
    |> validate_change(:type, fn _, type ->
      check_type(type, :signup)
    end)
    |> apply_action(:parse)
  end

  def invite_or_magic_link_params(attrs) do
    types = with_options()

    {%{}, types}
    |> cast(attrs, Map.keys(types) -- [:data])
    |> validate_required([:email, :type])
    |> validate_redirect_to()
    |> validate_inclusion(:type, ~w[invite magicLink]a)
    |> apply_action(:parse)
  end

  def recovery_params(attrs) do
    types = with_options()

    {%{}, types}
    |> cast(attrs, Map.keys(types) -- [:data])
    |> validate_redirect_to()
    |> validate_change(:type, fn _, type ->
      check_type(type, :recovery)
    end)
    |> validate_required([:email, :type])
    |> apply_action(:parse)
  end

  def email_change_params(attrs) do
    types = with_options()

    {%{}, types}
    |> cast(attrs, Map.keys(types) -- [:data])
    |> validate_required([:email, :type])
    |> validate_redirect_to()
    |> validate_inclusion(:type, ~w[email_change_current email_change_new]a)
    |> apply_action(:parse)
  end

  defp with_options(types \\ %{}) do
    @base_types
    |> Map.merge(types)
    |> Map.merge(@options_types)
  end

  defp check_type(current, desired) do
    if current == desired do
      []
    else
      [type: "need to be #{desired} for this schema"]
    end
  end

  defp validate_redirect_to(%{valid?: false} = changeset), do: changeset

  defp validate_redirect_to(changeset) do
    if redirect_to = get_change(changeset, :redirect_to) do
      case URI.new(redirect_to) do
        {:ok, uri} -> put_change(changeset, :redirect_to, URI.to_string(uri))
        {:error, error} -> add_error(changeset, :redirect_to, error)
      end
    else
      changeset
    end
  end
end
