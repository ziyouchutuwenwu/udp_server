-module(udp_server).

-export([start_link/3, init/3, loop/2]).

start_link(Port, UdpOptions, ConfigBehaviorImpl) ->
  Pid = spawn_link(?MODULE,init,[Port, UdpOptions, ConfigBehaviorImpl]),
  {ok, Pid}.

init(Port, UdpOptions, ConfigBehaviorImpl) ->
  {ok, Socket} = gen_udp:open(Port, UdpOptions),
  loop(Socket, ConfigBehaviorImpl).

loop(Socket, ConfigBehaviorImpl) ->
  receive
    {udp, Socket, Host, Port, Bin} ->
      case client_info_saver:find(Host, Port) of
        {err, not_found} ->
          inet:setopts(Socket, [{active, 3}]),
          {ok, NewPid} = udp_client_sup:start_child(Socket, ConfigBehaviorImpl),
          client_info_saver:set(Host, Port, NewPid),
          NewPid! {udp, newsock, self(), Host, Port, Bin},
          loop(Socket, ConfigBehaviorImpl);
        {ok, Pid} ->
          Pid ! {udp, data, Socket, Host, Port, Bin},
          loop(Socket, ConfigBehaviorImpl)
      end;
    {child_pid_exit, Host, Port} ->
      client_info_saver:remove(Host, Port),
      loop(Socket, ConfigBehaviorImpl);
    {udp_passive, Socket} ->
      inet:setopts(Socket, [{active, 3}]),
      loop(Socket, ConfigBehaviorImpl);
    Other ->
      io:format("server got other msg ~p~n", [Other])
  end.