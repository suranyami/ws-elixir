defmodule WebsocketsServer do
  @behaviour :application

  defp start_app(app) do
    status = :application.start app
    IO.puts "Starting up #{app}... #{inspect status}"
  end

  def start do
    start_app :cowboy
    start_app :gproc
    start_app WebsocketsServer
  end

  def start(_type, _args) do
    dispatch = [{:_, [
      {["ws"], FileHandler, []},
      {["_ws"], WebsocketsHandler,
        [{:dumb_protocol, DumbIncrementHandler},
         {:mirror_protocol, MirrorHandler}]},
      {:_, HelloHandler, []}
    ]}]
    :cowboy.start_listener :my_http_listener, 100,
      :cowboy_tcp_transport, [{:port, 8080}],
      :cowboy_http_protocol, [{:dispatch, dispatch}]

    WebsocketsSupervisor.start_link
  end

  def stop(_state) do
    :ok
  end
end
