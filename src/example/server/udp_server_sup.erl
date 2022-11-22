-module(udp_server_sup).

-behaviour(supervisor).

-export([start_link/3]).
-export([init/1]).

start_link(Port, UdpOptions, ConfigBehaviorImpl) ->
  supervisor:start_link({local,?MODULE}, ?MODULE, [Port, UdpOptions, ConfigBehaviorImpl]).

init([Port, UdpOptions, ConfigBehaviorImpl]) ->
  MaxRestarts = 5,
  MaxSecondsBetweenRestarts = 10,

  SupervisorFlags =
    #{strategy => one_for_one,
      intensity => MaxRestarts,
      period => MaxSecondsBetweenRestarts},

  ChildSpec =
    #{id => udp_server,
      start => {udp_server, start_link, [Port, UdpOptions, ConfigBehaviorImpl]},
      restart => transient,
      shutdown => brutal_kill,
      type => worker,
      modules => [udp_server]},

  Children = [ChildSpec],
  {ok, {SupervisorFlags, Children}}.