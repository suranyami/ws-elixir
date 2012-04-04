defmodule HelloHandler do
  @behaviour :cowboy_http_handler

  def init({ _any, :http }, request, []) do
    { :ok, request, :undefined }
  end

  def handle(request, state) do
    { :ok, new_req } = :cowboy_http_req.reply 200, [], "Hello world!", request
    { :ok, new_req, state }
  end

  def terminate(_request, _state) do
    :ok
  end
end
