defmodule FileHandler do
  @behaviour :cowboy_http_handler
  @moduledoc """
  This is an HTTP handler that will server a single file to the
  client.
  """

  def init({_any, :http}, req, []) do
    { :ok, req, :undefined}
  end

  def handle(req, state) do
    {:ok, html_data} = File.read("assets/test.html")
    {:ok, new_req} = :cowboy_http_req.reply(200, [{:'Content-Type', "text/html"}], html_data, req)
    {:ok, new_req, state}
  end

  def terminate(_req, _state) do
    :ok
  end
end

