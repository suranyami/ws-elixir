defmodule WebSocketServer do
  @behaviour :application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [
        {'/ws',  FileHandler, []},
        {'/_ws', WebSocketHandler, [{"dumb-increment-protocol",   DumbIncrementHandler},
                                    {"mirror-protocol", MirrorHandler}]},
        {'/',    HelloHandler, []}
      ]}
    ])
    :cowboy.start_http :my_http_listener, 100, [{:port, 8080}], [{:env, [{:dispatch, dispatch}]}]
    IO.puts "Started listening on port 8080..."

    WebSocketSup.start_link
  end

  def stop(_state) do
    :ok
  end
end
