defmodule Probe.Controllers.Run do
  use Probe, :controller

  @run_timeout 10_000

  action_fallback Probe.Controllers.Fallback

  def start(conn, %{"token" => token}) do
    # session_id = Map.get(params, "session_id")

    # The home page is often custom made,
    # so skip the default app layout.

    with {:ok, %{topic: topic, port: port} = attrs} <-
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

        run = Probe.Repo.reload(run)
        Probe.PubSub.broadcast("run:#{topic}", {:failed, %{checks: run.checks}})
      end)

      send_resp(conn, 200, "#{port}")
    else
      _ ->
        send_resp(conn, 401, "invalid or expired token")
    end
  end

  defp get_remote_ip_location(conn) do
    result = Geolix.lookup(conn.remote_ip, [])
    region = get_in(result, [:city, :continent, :name])
    country = get_in(result, [:city, :country, :iso_code]) || "Unknown"
    city = get_in(result, [:city, :city, :name])
    latitude = get_in(result, [:city, :location, :latitude])
    longitude = get_in(result, [:city, :location, :longitude])
    provider = get_in(result, [:asn, :autonomous_system_organization])
    {city, region, country, latitude, longitude, provider}
  end

  def show(conn, %{"token" => token}) do
    with {:ok, %{topic: topic}} <-
           Phoenix.Token.verify(Probe.Endpoint, "topic", token, max_age: :infinity) do
      run = Probe.Runs.fetch_run_by_topic!(topic)

      send_resp(conn, 200, ~s"""
        Status: #{run.status}
        Port: #{run.port}
        Country: #{run.remote_ip_location_country}
        Latitude: #{run.remote_ip_location_lat}
        Longitude: #{run.remote_ip_location_lon}
        Started: #{run.inserted_at}
        Ended: #{run.updated_at}
      """)
    else
      _ ->
        send_resp(conn, 401, "invalid or expired token")
    end
  end

  # defp get_load_balancer_ip_location(%Plug.Conn{} = conn) do
  #   location_region =
  #     case Plug.Conn.get_req_header(conn, "x-geo-location-region") do
  #       ["" | _] -> nil
  #       [location_region | _] -> location_region
  #       [] -> nil
  #     end

  #   location_city =
  #     case Plug.Conn.get_req_header(conn, "x-geo-location-city") do
  #       ["" | _] -> nil
  #       [location_city | _] -> location_city
  #       [] -> nil
  #     end

  #   {location_lat, location_lon} =
  #     case Plug.Conn.get_req_header(conn, "x-geo-location-coordinates") do
  #       ["" | _] ->
  #         {nil, nil}

  #       ["," | _] ->
  #         {nil, nil}

  #       [coordinates | _] ->
  #         [lat, lon] = String.split(coordinates, ",", parts: 2)
  #         lat = String.to_float(lat)
  #         lon = String.to_float(lon)
  #         {lat, lon}

  #       [] ->
  #         {nil, nil}
  #     end

  #   {location_lat, location_lon} =
  #     Domain.Geo.maybe_put_default_coordinates(location_region, {location_lat, location_lon})

  #   {location_region, location_city, {location_lat, location_lon}}
  # end

  # def index(conn, _params) do
  #   bars = Foo.list_bars()
  #   render(conn, :index, bars: bars)
  # end

  # def create(conn, %{"bar" => bar_params}) do
  #   with {:ok, %Bar{} = bar} <- Foo.create_bar(bar_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/bars/#{bar}")
  #     |> render(:show, bar: bar)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   bar = Foo.get_bar!(id)
  #   render(conn, :show, bar: bar)
  # end

  # def update(conn, %{"id" => id, "bar" => bar_params}) do
  #   bar = Foo.get_bar!(id)

  #   with {:ok, %Bar{} = bar} <- Foo.update_bar(bar, bar_params) do
  #     render(conn, :show, bar: bar)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   bar = Foo.get_bar!(id)

  #   with {:ok, %Bar{}} <- Foo.delete_bar(bar) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
