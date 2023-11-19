defmodule Supabase.GoTrue.Auth do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :url, :map
    field(:expiry_margin, :integer, default: 10)

    embeds_one :mfa, MFA, primary_key: false do
      embeds_one :enroll, Enroll, primary_key: false do
        field(:factor_type, Ecto.Enum, values: [:totp])
        field(:issue, :string)
        field(:friendly_name, :string)
      end

      embeds_one :unenroll, UnEnroll, primary_key: false do
        field(:factor_id, :string)
      end

      embeds_one :verify, Verify, primary_key: false do
        field(:factor_id, :string)
        field(:challenge_id, :string)
        field(:code, :string)
      end

      embeds_one :challenge, Challenge, primary_key: false do
        field(:factor_id, :string)
      end

      embeds_one :challenge_and_verify, ChallengeAndVerify, primary_key: false do
        field(:factor_id, :string)
        field(:code, :string)
      end
    end

    embeds_one :network_failure, NetWorkFailure, primary_key: false do
      field(:max_retries, :integer, default: 10)
      field(:retry_interval, :integer, default: 2)
    end
  end

  def parse(attrs, mfa \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, ~w[expiry_margin]a)
    |> put_assoc(:mfa, mfa, required: true)
    |> cast_assoc(:network_failure, with: &network_failure_changeset/2, required: true)
  end

  defp network_failure_changeset(failure, attrs) do
    cast(failure, attrs, ~w[max_retries max_interval])
  end

  def parse_mfa(attrs) do
    %__MODULE__.MFA{}
    |> cast(attrs, [])
    |> cast_assoc(:enroll, with: &enroll_changeset/2, required: true)
    |> cast_assoc(:unenroll, with: &unenroll_changeset/2, required: true)
    |> cast_assoc(:verify, with: &verify_changeset/2, required: true)
    |> cast_assoc(:challenge, with: &challenge_changeset/2, required: true)
    |> cast_assoc(:challenge_and_verify, with: &challenge_and_verify_changeset/2, required: true)
    |> apply_action(:parse)
  end

  defp enroll_changeset(enroll, attrs) do
    enroll
    |> cast(attrs, ~w[factor_type issuer friendly_name]a)
    |> validate_required([:factor_type])
  end

  defp unenroll_changeset(unenroll, attrs) do
    unenroll
    |> cast(attrs, [:factor_id])
    |> validate_required([:factor_id])
  end

  defp verify_changeset(verify, attrs) do
    verify
    |> cast(attrs, [:factor_id, :challenge_id, :code])
    |> validate_required([:factor_id, :challenge_id, :code])
  end

  defp challenge_changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:factor_id])
    |> validate_required([:factor_id])
  end

  defp challenge_and_verify_changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:factor_id, :code])
    |> validate_required([:factor_id, :code])
  end
end
