defmodule HelloHandler do
  @behaviour :cowboy_http_handler

  def init({ _any, :http }, request, _) do
    { :ok, request, :undefined }
  end

  def handle(request, state) do
    { path, ^request} = :cowboy_http_req.path(request)
    case File.read File.join(path) do
    match: { :ok, data }
        { :ok, new_req } = :cowboy_http_req.reply 200, [], data, request
    else:
        { :ok, new_req } = :cowboy_http_req.reply 200, [], "Hello world!", request
    end
    { :ok, new_req, state }
  end

  def terminate(_request, _state) do
    :ok
  end
end
