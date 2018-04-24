-module(amoveo_exchange_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).
-define(SERVER, ?MODULE).
-define(keys, [id_lookup, unconfirmed_veo, unconfirmed_bitcoin, order_book, balance_veo, order_book_data]).
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
child_maker([]) -> [];
child_maker([H|T]) -> [?CHILD(H, worker)|child_maker(T)].
init([]) ->
    Workers = child_maker(?keys),
    {ok, { {one_for_all, 0, 1}, Workers} }.
