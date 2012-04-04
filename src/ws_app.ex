defmodule WebsocketsServer do
  @behaviour :application

  def start do
    status = :application.start :cowboy
    IO.puts "Starting up cowboy... #{inspect status}"

    status = :application.start __MODULE__
    IO.puts "Starting up the server... #{inspect status}"
  end

  def start(_type, _args) do
    dispatch = [{:_, [{:_, HelloHandler, []}]}]
    :cowboy.start_listener :my_http_listener, 100,
      :cowboy_tcp_transport, [{:port, 8080}],
      :cowboy_http_protocol, [{:dispatch, dispatch}]

    WebsocketsSupervisor.start_link
  end

  def stop(_state) do
    :ok
  end
end
