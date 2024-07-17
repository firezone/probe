defmodule Probe.Controllers.Run do
  use Probe, :controller
  alias Probe.Token
  alias Probe.Runs
  require Logger

  action_fallback Probe.Controllers.Fallback

  def start(conn, %{"token" => token}) do
    with {:ok, %{pid: pid, port: port} = t} <- Token.verify(token) do
      {city, region, country, latitude, longitude, provider} = get_remote_ip_location(conn)

      attrs = %{
        port: port,
        remote_ip_location_country: country,
        remote_ip_location_region: region,
        remote_ip_location_city: city,
        remote_ip_location_lat: latitude,
        remote_ip_location_lon: longitude,
        remote_ip_provider: provider
      }

      {:ok, run} = Probe.Runs.start_run(pid, attrs)

      send_resp(conn, 200, init_data(run))
    else
      error ->
        Logger.error("Failed to start run: #{inspect(error)}")
        send_resp(conn, 401, "invalid or expired token")
    end
  end

  def complete(conn, %{"id" => id}) do
    {:ok, run} = Probe.Runs.fetch_run(id)
    Probe.Runs.complete_run(run)
    send_resp(conn, 200, "")
  end

  def cancel(conn, %{"id" => id}) do
    {:ok, run} = Probe.Runs.fetch_run(id)
    Probe.Runs.cancel_run(run)
    send_resp(conn, 200, "")
  end

  def show(conn, %{"id" => id}) do
    {:ok, run} = Probe.Runs.fetch_run(id)

    send_resp(conn, 200, ~s"""
    ID: #{run.id}
    Checks:
      #{format_checks(run.checks)}
    Started: #{run.started_at}
    Ended: #{run.completed_at}
    Port: #{run.port}
    City: #{run.remote_ip_location_city}
    Region: #{run.remote_ip_location_region}
    Country: #{run.remote_ip_location_country}
    Latitude: #{run.remote_ip_location_lat}
    Longitude: #{run.remote_ip_location_lon}
    """)
  end

  defp get_remote_ip_location(conn) do
    remote_ip = get_client_ip(conn)
    result = Geolix.lookup(remote_ip, [])
    region = get_in(result.city.continent.name)
    country = get_in(result.city.country.iso_code) || "Unknown"
    city = get_in(result.city.city.name)
    latitude = get_in(result.city.location.latitude)
    longitude = get_in(result.city.location.longitude)
    provider = get_in(result.asn.autonomous_system_organization)
    {city, region, country, latitude, longitude, provider}
  end

  defp get_client_ip(conn) do
    case Plug.Conn.get_req_header(conn, "fly-client-ip") do
      [ip | _] -> ip
      [] -> conn.remote_ip
    end
  end

  defp format_checks(checks) do
    checks
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
    |> Enum.join("\n  ")
  end

  defp init_data(run) do
    {:ok, ip} = :inet.getaddr(String.to_charlist(Probe.Endpoint.host()), :inet)

    ~s"""
    #{url(~p"/runs/#{run.id}")}
    #{run.port}
    #{:inet.ntoa(ip)}
    #{Base.encode64(Runs.UDPServer.generate_handshake_initiation_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_handshake_response_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_cookie_reply_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_data_message_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_turn_handshake_initiation_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_turn_handshake_response_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_turn_cookie_reply_payload(run))}
    #{Base.encode64(Runs.UDPServer.generate_turn_data_message_payload(run))}
    """
  end
end
