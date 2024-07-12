defmodule Probe.Controllers.Run do
  use Probe, :controller
  alias Probe.Runs.UdpServer

  @run_timeout 15_000

  action_fallback Probe.Controllers.Fallback

  def start(conn, %{"token" => token}) do
    with {:ok, %{topic: topic} = attrs} <-
           Phoenix.Token.verify(Probe.Endpoint, "topic", token, max_age: 60) do
      Probe.PubSub.broadcast("run:#{topic}", {:started, %{remote_ip: conn.remote_ip}})

      {city, region, country, latitude, longitude, provider} = get_remote_ip_location(conn)

      attrs =
        Map.merge(attrs, %{
          remote_ip_location_country: country,
          remote_ip_location_region: region,
          remote_ip_location_city: city,
          remote_ip_location_lat: latitude,
          remote_ip_location_lon: longitude,
          remote_ip_provider: provider
        })

      {:ok, run} = Probe.Runs.start_run(attrs)

      Task.start(fn ->
        Process.sleep(@run_timeout)
        Probe.PubSub.broadcast("run:#{topic}", {:completed, run.id})
      end)

      send_resp(conn, 200, init_data(run))
    else
      _ ->
        send_resp(conn, 401, "invalid or expired token")
    end
  end

  def complete(conn, %{"token" => token}) do
    with {:ok, %{topic: topic}} <-
           Phoenix.Token.verify(Probe.Endpoint, "topic", token, max_age: 60),
         {:ok, run} = Probe.Runs.fetch_run_by_topic(topic) do
      Probe.PubSub.broadcast("run:#{topic}", {:completed, run.id})

      send_resp(conn, 200, "")
    else
      _ ->
        send_resp(conn, 401, "invalid or expired token")
    end
  end

  def cancel(conn, %{"token" => token}) do
    with {:ok, %{topic: topic}} <-
           Phoenix.Token.verify(Probe.Endpoint, "topic", token, max_age: 60),
         {:ok, run} = Probe.Runs.fetch_run_by_topic(topic) do
      Probe.PubSub.broadcast("run:#{topic}", {:canceled, run.id})

      send_resp(conn, 200, "")
    else
      _ ->
        send_resp(conn, 401, "invalid or expired token")
    end
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

  def show(conn, %{"token" => token}) do
    with {:ok, %{topic: topic}} <-
           Phoenix.Token.verify(Probe.Endpoint, "topic", token, max_age: :infinity),
         {:ok, run} = Probe.Runs.fetch_run_by_topic(topic) do
      send_resp(conn, 200, ~s"""
        Checks: #{inspect(run.checks)}
        Started: #{run.started_at}
        Ended: #{run.completed_at}
        Port: #{run.port}
        City: #{run.remote_ip_location_city}
        Region: #{run.remote_ip_location_region}
        Country: #{run.remote_ip_location_country}
        Latitude: #{run.remote_ip_location_lat}
        Longitude: #{run.remote_ip_location_lon}
      """)
    else
      _ ->
        send_resp(conn, 401, "invalid or expired token")
    end
  end

  defp init_data(run) do
    {:ok, ip} = :inet.getaddr(String.to_charlist(Probe.Endpoint.host()), :inet)

    ~s"""
    #{run.port}
    #{:inet.ntoa(ip)}
    #{Base.encode64(UdpServer.generate_handshake_initiation_payload(run))}
    #{Base.encode64(UdpServer.generate_handshake_response_payload(run))}
    #{Base.encode64(UdpServer.generate_cookie_reply_payload(run))}
    #{Base.encode64(UdpServer.generate_data_payload(run))}
    """
  end
end
