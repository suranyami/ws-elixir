#!/bin/sh

elixir --no-halt -pa ebin -pa deps/cowboy/ebin -e "WebsocketsServer.start"
