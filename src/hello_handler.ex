defmodule HelloHandler do
  @behaviour :cowboy_http_handler

  def init({ _any, :http }, request, _) do
    { :ok, request, :undefined }
  end

  def handle(request, state) do
    case :cowboy_http_req.path(request) do
    match: { [h|t] = path, ^request}
      handle_file path, request, state
    match: other
      { :ok, new_req } = :cowboy_http_req.reply 200, [], "Hello world!", request
      { :ok, new_req, state }
    end
  end

  def terminate(_request, _state) do
    :ok
  end

  defp handle_file(path, request, state) do
    case File.read(File.join(path)) do
    match: { :ok, data }
      { :ok, new_req } = :cowboy_http_req.reply 200, [], data, request
    match: other
      { :ok, new_req } = :cowboy_http_req.reply 404, request
    end
    { :ok, new_req, state }
  end
end
