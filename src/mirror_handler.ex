defmodule MirrorHandler do
  @behaviour :simple_handler

  def init(_any, req) do
    IO.puts "Mirror options = #{inspect opts}"
    subscribe
    {:ok, req, nil}
  end

  # All it does is send the message back to all clients,
  # including the sender itself
  def stream(msg, req, state) do
    broadcast msg
    {:reply, msg, req, state}
  end

  # A callback from gproc to broadcast msg to all clients
  def info({:mirror_protocol, msg}, req, state) do
    {:reply, {:text, msg}, req, state, :hibernate}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end


  ## Private functions ##

  def subscribe do
    :gproc.reg({:p, :l, :mirror_protocol})
  end

  def broadcast(msg) do
    :gproc.send {:p, :l, :mirror_protocol},
                {:mirror_protocol, msg}
  end
end
