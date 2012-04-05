defmodule WebsocketsHandler do
  @behaviour :cowboy_http_handler
  @behaviour :cowboy_http_websocket_handler

  defrecord State, counter: 0

  def init({_any, :http}, req, []) do
    case :cowboy_http_req.header(:Upgrade, req) do
    match: {:undefined, new_req}
      { :ok, new_req, :undefined}
    match: {"websocket", _req}
      { :upgrade, :protocol, :cowboy_http_websocket }
    end
  end

  def handle(req, state) do
    {:ok, html_data} = File.read("assets/test.html")
    {:ok, new_req} = :cowboy_http_req.reply(200, [{:'Content-Type', "text/html"}], html_data, req)
    {:ok, new_req, state}
  end

  def terminate(_req, _state) do
    :ok
  end

  def websocket_init(_any, req, []) do
    { headers, _ } = :cowboy_http_req.headers(req)
    proto = Enum.keyfind headers,
                         "Sec-Websocket-Protocol",
                         1
    if proto === {"Sec-Websocket-Protocol", "mirror-protocol"} do
      subscribe_for_event(:mirror_protocol)
    end

    :timer.send_interval(50, :tick)
    {:ok, :cowboy_http_req.compact(req), State.new, :hibernate}
  end

  def websocket_handle({:text, "reset\n"}, req, state) do
    {:ok, req, state.counter(0), :hibernate}
  end

  def websocket_handle({:text, msg}, req, state) do
    broadcast_message(msg)
    {:reply, {:text, msg}, req, state, :hibernate}
  end

  def websocket_handle(_any, req, state) do
    {:ok, req, state}
  end

  def websocket_info(:tick, req, state) do
    {:reply,
      {:text, to_binary(state.counter)},
      req,
      state.increment_counter,
      :hibernate}
  end

  # A callback from gproc to broadcast msg to all clients
  def websocket_info({:mirror_protocol, msg}, req, state) do
    {:reply, {:text, msg}, req, state, :hibernate}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state, :hibernate}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end


  ## Private functions ##

  def subscribe_for_event(event) do
    :gproc.reg({:p, :l, event})
  end

  def broadcast_message(msg) do
    :gproc.send {:p, :l, :mirror_protocol},
                {:mirror_protocol, msg}
  end
end
