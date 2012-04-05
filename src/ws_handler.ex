defmodule WebsocketsHandler do
  @behaviour :cowboy_http_handler
  @behaviour :cowboy_http_websocket_handler


  ## This is the part where we handle our WebSocket protocols

  defrecord State, handler: nil, handler_state: nil

  defp timeout, do: 60000

  def websocket_init(_any, req, opts) do
    { headers, _ } = :cowboy_http_req.headers(req)
    proto = Enum.keyfind headers, "Sec-Websocket-Protocol", 1
    handler =
      case proto do
      match: {"Sec-Websocket-Protocol", "dumb-increment-protocol"}
        {_, handler} = Enum.keyfind opts, :dumb_protocol, 1
        handler

      match: {"Sec-Websocket-Protocol", "mirror-protocol"}
        {_, handler} = Enum.keyfind opts, :mirror_protocol, 1
        handler
      end

    case handler.init(_any, req) do
    match: {:ok, req, state}
      req = :cowboy_http_req.compact req
      {:ok, req, State.new(handler: handler,
        handler_state: state), timeout, :hibernate}

    match: {:shutdown, req, _state}
      {:shutdown, req}
    end
  end

  def websocket_handle({:text, msg}, req, state) do
    handler = state.handler
    handler_state = state.handler_state
    case handler.stream(msg, req, handler_state) do
    match: {:ok, req, new_state}
      {:ok, req, State.handler_state(new_state), :hibernate}

    match: {:reply, reply, req, new_state}
      {:reply, {:text, reply}, req,
        State.handler_state(new_state), :hibernate}
    end
  end

  def websocket_handle(_any, req, state) do
    {:ok, req, state}
  end

  def websocket_info(info, req, state) do
    handler = state.handler
    handler_state = state.handler_state
    case handler.info(info, req, handler_state) do
    match: {:ok, req, new_state}
      {:ok, req, State.handler_state(new_state), :hibernate}

    match: {:reply, reply, req, new_state}
      {:ok, {:text, reply}, req,
        State.handler_state(state), :hibernate}
    end
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end


  ## This is the HTTP part of the handler. It will only start up
  ## properly, if the request is asking to upgrade the protocol to
  ## WebSocket

  defp not_implemented(req) do
    { :ok, req } = :cowboy_http_req.reply(501, [], [], req)
    { :shutdown, req, :undefined }
  end

  def init({_any, :http}, req, _opts) do
    case :cowboy_http_req.header(:Upgrade, req) do
    match: {bin, req} when is_binary(bin)
      case :cowboy_bstr.to_lower(bin) do
      match: "websocket"
        { :upgrade, :protocol, :cowboy_http_websocket }
      else:
        not_implemented req
      end
    match: {:undefined, req}
      not_implemented req
    end
  end

  def handle(req, _state) do
    not_implemented req
  end

  def terminate(_req, _state) do
    :ok
  end
end
