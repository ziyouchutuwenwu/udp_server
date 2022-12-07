-module(client_info_saver).

-export([set/3]).
-export([find/2]).
-export([remove/2]).

set(Ip, Port, Pid)->
  put({Ip, Port}, Pid).

find(Ip, Port)->
  case get({Ip, Port}) of
    undefined ->
      {err, not_found};
    Pid ->
      {ok, Pid}
  end.

remove(Ip, Port)->
  erase({Ip, Port}).