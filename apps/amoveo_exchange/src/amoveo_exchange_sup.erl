-module(amoveo_exchange_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1, stop/0]).
-define(SERVER, ?MODULE).
-define(keys, [accounts, trades, trade_limit, message_limit]).
child_killer([]) -> [];
child_killer([H|T]) -> 
    supervisor:terminate_child(?MODULE, H),
    child_killer(T).
stop() -> child_killer(?keys).
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
child_maker([]) -> [];
child_maker([H|T]) -> [?CHILD(H, worker)|child_maker(T)].
init([]) ->
    Workers = child_maker(?keys),
    {ok, { {one_for_all, 0, 1}, Workers} }.
