# DPI due to following issues:
# -Use of port 51280
# -Message tag (0x1 - 0x4)
# -Fixed message lengths (148/92/64 for initiation/response/cookie)
# -16 zero bytes at the end of initiation and response messages (MAC2)

defmodule Probe.Runs.Check do
  use Probe, :schema

  schema "run_checks" do
    belongs_to :run, Probe.Runs.Run

    field :adapter, Ecto.Enum,
      values: [
        :vanilla,
        :non_standard_port,
        :random_initial_mac2,
        :variable_message_length
      ]

    field :status, Ecto.Enum,
      values: [
        :pending,
        :in_progress,
        :completed,
        :failed
      ],
      default: :pending

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(%__MODULE__{} = check \\ %__MODULE__{}, attrs) do
    check
    |> cast(attrs, [:adapter, :status])
  end
end
