-module(udp_client_demo).

-export([demo/0]).
-export([loop/3]).
-export([spawn_proc_to_send/2, loop_to_send/2]).
-export([batch_connect/3]).
-export([udp_opts/0]).


demo()->
  batch_connect("127.0.0.1", 1111, 1).

batch_connect(Host, Port, Numbers) ->
  IndexList = lists:seq(1, Numbers),
    lists:foreach(
      fun(_Index) ->
        spawn_proc_to_send(Host, Port)
      end,
      IndexList
    ).

udp_opts() ->
  [binary,{reuseaddr, true}].

spawn_proc_to_send(Host, Port) ->
  Pid = spawn_link(?MODULE, loop_to_send,[Host, Port]),
  {ok, Pid}.

loop_to_send(Host, Port)->
  {ok, Socket} = gen_udp:open(0, udp_opts()),
  loop(Socket, Host, Port).

loop(Socket, Ip, Port) ->
  ok = gen_udp:send(Socket, Ip, Port, "11111111111"),
  erlang:send_after(5000, self(), {on_timer}),

  receive
    {udp, Socket, _, _, Bin} ->
      io:format("client got msg ~p~n", [Bin]),
      gen_udp:send(Socket, Ip, Port, "22222"),
      loop(Socket, Ip, Port);
    {on_timer} ->
      io:format("on_timer~n"),
      gen_udp:close(Socket)
  after 20000 ->
    error
  end.