-module(time_helper).

-export([time_to_unix_timestamp/0]).

time_to_unix_timestamp()->
  {M, S, _} = os:timestamp(),
  M * 1000000 + S.