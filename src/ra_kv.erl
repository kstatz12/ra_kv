-module(ra_kv).
-behaviour(ra_machine).
-export([init/1, apply/4]).
-export([write/2]).
-export([start/0]).

write(Server, Key) ->
    ra:process_command(Server, {write, k, v}).

init(_Config) ->
    #{}.


apply(_Meta, {write, Key, Value}, _, State) ->
    NewState = maps:put(Key, Value, State),
    {NewState, []};
apply(_Meta, {read, Key}, _, State) ->
    Reply = maps:get(Key, State, []),
    {State, Reply, []}.


start() ->
    %% the initial cluster members
    Members = [{ra_kv1, node()}, {ra_kv2, node()}, {ra_kv3, node()}],
    %% an arbitrary cluster name
    ClusterName = <<"ra_kv">>,
    %% the config passed to `init/1`, must be a `map`
    Config = #{},
    %% the machine configuration
    Machine = {module, ?MODULE, Config},
    %% ensure ra is started
    application:ensure_all_started(ra),
    %% start a cluster instance running the `ra_kv` machine
    ra:start_cluster(ClusterName, Machine, Members).

