-module(udp_client_handler).

-export([start_link/2, init/2, recv_loop/2]).

start_link(Socket, ConfigBehaviorImpl) ->
  Pid = spawn_link(?MODULE, init, [Socket, ConfigBehaviorImpl]),
  {ok, Pid}.

init(Socket, ConfigBehaviorImpl)->
  recv_loop(Socket, ConfigBehaviorImpl).

recv_loop(Socket, ConfigBehaviorImpl) ->
  receive
    {udp, newsock, ParentPid, Host, Port, Bin} ->
      TimerRef = erlang:start_timer(5000, self(), {on_timer}),
      put(timer, {ref, TimerRef, left, time_helper:time_to_unix_timestamp()}),
      put(parent_communicate_info, {parent_pid, ParentPid, host, Host, port, Port}),

      SocketHandlerModule = ConfigBehaviorImpl:get_socket_handler_module(),
      SocketHandlerModule:on_client_data(Socket, Host, Port, Bin),

      recv_loop(Socket, ConfigBehaviorImpl);
    {udp, data, Socket, Host, Port, Bin} ->
      {ref, PreTimerRef, left, _PreTimeStamp} = get(timer),
      erlang:cancel_timer(PreTimerRef),
      TimerRef = erlang:start_timer(5000, self(), {on_timer}),
      put(timer, {ref, TimerRef, left, time_helper:time_to_unix_timestamp()}),

      SocketHandlerModule = ConfigBehaviorImpl:get_socket_handler_module(),
      SocketHandlerModule:on_client_data(Socket, Host, Port, Bin),

      recv_loop(Socket, ConfigBehaviorImpl);
    % 超时，通知父进程，并且自己退出
    {timeout, TimerRef, {on_timer}}->
      {parent_pid, ParentPid, host, Host, port, Port} = get(parent_communicate_info),
      ParentPid ! {child_pid_exit, Host, Port},
      erlang:cancel_timer(TimerRef),
      erase(timer)
  end.