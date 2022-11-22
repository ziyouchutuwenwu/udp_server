-module(config_behavior_impl).

-export([get_socket_handler_module/0]).

get_socket_handler_module() ->
  demo_udp_server_handler_impl.