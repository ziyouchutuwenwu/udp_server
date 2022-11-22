-module(demo_udp_server_handler_impl).

-behaviour(udp_server_handler_behavior).

-export([on_client_data/4]).

on_client_data(_Socket, _ClientIp, _ClientPort, DataBin) ->
  Info = binary_to_list(DataBin),
  io:format("收到客户端数据 ~p~n", [Info]),
  noreplay.