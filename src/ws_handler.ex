defmodule WebsocketsHandler do
  @behaviour :cowboy_http_handler
  @behaviour :cowboy_http_websocket_handler

  def init({_any, :http}, req, []) do
    case :cowboy_http_req.header(:Upgrade, req) do
    match: {:undefined, new_req}
      { :ok, new_req, :undefined}
    match: {"websocket", _req}
      { :upgrade, :protocol, :cowboy_http_websocket }
    match: {"WebSocket", _req}
      { :upgrade, :protocol, :cowboy_http_websocket }
    end
  end

  def handle(req, state) do
    {:ok, new_req} = :cowboy_http_req.reply(200, [{:'Content-Type', "text/html"}],
  ## HTML code taken from misultin's example file.
  "<html>
  <head>
  <script type=\"text/javascript\">
  function addStatus(text){
    var date = new Date();
    document.getElementById('status').innerHTML
      = document.getElementById('status').innerHTML
      + date + \": \" + text + \"<br/>\";
  }
  function ready(){
    if (\"MozWebSocket\" in window) {
      WebSocket = MozWebSocket;
    }
    if (\"WebSocket\" in window) {
      // browser supports websockets
      var ws = new WebSocket(\"ws://localhost:8080/websocket\");
      ws.onopen = function() {
        // websocket is connected
        addStatus(\"websocket connected!\");
        // send hello data to server.
        ws.send(\"hello server!\");
        addStatus(\"sent message to server: 'hello server'!\");
      };
      ws.onmessage = function (evt) {
        var receivedMsg = evt.data;
        addStatus(\"server sent the following: '\" + receivedMsg + \"'\");
      };
      ws.onclose = function() {
        // websocket was closed
        addStatus(\"websocket was closed\");
      };
    } else {
      // browser does not support websockets
      addStatus(\"sorry, your browser does not support websockets.\");
    }
  }
  </script>
  </head>
  <body onload=\"ready();\">
  Hi!
  <div id=\"status\"></div>
  </body>
  </html>", req)
    {:ok, new_req, state}
  end

  def terminate(_req, _state) do
    :ok
  end

  def websocket_init(_any, req, []) do
    :timer.send_interval(1000, :tick)
    new_req = :cowboy_http_req.compact(req)
    {:ok, new_req, :undefined, :hibernate}
  end

  def websocket_handle({:text, msg}, req, state) do
    {:reply, {:text, "You said: " <> msg}, req, state, :hibernate}
  end

  def websocket_handle(_any, req, state) do
    {:ok, req, state}
  end

  def websocket_info(:tick, req, state) do
    {:reply, {:text, "Tick"}, req, state, :hibernate}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state, :hibernate}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
