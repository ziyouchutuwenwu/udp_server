-module(demo).

%% -compile(export_all).
-export([udp_opts/0, start/0]).

udp_opts() ->
  [binary, {reuseaddr, true}].
start() ->
  udp_server_sup:start_link(1111, udp_opts(), config_behavior_impl).