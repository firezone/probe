defmodule Probe.Controllers.Run do
  use Probe, :controller

  action_fallback Probe.Controllers.Fallback

  def start(conn, _params) do
    # session_id = Map.get(params, "session_id")

    # {location_region, location_city, {location_lat, location_lon}} =
    #   get_load_balancer_ip_location(conn)

    # attrs = %{
    #   remote_ip_location_country: "US",
    #   remote_ip_location_region: location_region,
    #   remote_ip_location_city: location_city,
    #   remote_ip_location_lat: location_lat,
    #   remote_ip_location_lon: location_lon,
    #   remote_ip_provider: "AT&T"
    # }

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
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
