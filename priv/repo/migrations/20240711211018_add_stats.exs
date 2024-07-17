defmodule Probe.Repo.Migrations.AddStats do
  use Ecto.Migration

  def change do
    execute("""
    CREATE MATERIALIZED VIEW country_stats_mv AS
      SELECT remote_ip_location_country AS country,
             COUNT(DISTINCT CASE
               WHEN checks @> '{"cookie_reply":true,"data_message":true,"turn_cookie_reply":true,"turn_data_message":true}'::jsonb THEN anonymized_id
              END) AS num_succeeded,
             COUNT(DISTINCT anonymized_id) AS num_completed,
             NOW() AS updated_at
      FROM runs
      WHERE completed_at IS NOT NULL
        AND canceled_at IS NULL
        AND remote_ip_location_country IS NOT NULL
        AND remote_ip_location_country != 'Unknown'
      GROUP BY remote_ip_location_country
      ORDER BY remote_ip_location_country ASC;
    """)

    execute("CREATE UNIQUE INDEX country_stats_mv_country_idx ON country_stats_mv (country ASC);")
  end
end
