-module(unconfirmed_veo_feeder).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 confirm/1, confirm_all/0, trade/1, 
	 stale_refunds/0,
	 stale_trades_cron/0,
	 confirm_veo_cron/0]).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(confirm_all, X) -> 
    lists:map(fun(TID) -> unconfirmed_veo:confirm(TID) end,
	      unconfirmed_veo:keys()),
    {noreply, X};
handle_cast({confirm, TID}, X) -> 
    unconfirmed_veo:confirm(TID),
    {noreply, X};
handle_cast({trade, Trade}, X) -> 
    unconfirmed_veo:trade(Trade),
    {noreply, X};
handle_cast(stale_refunds, X) ->
    lists:map(fun(TID) -> unconfirmed_veo:stale_refunds(TID) end,
	      unconfirmed_veo:keys()),
    {noreply, X};
handle_cast(_, X) -> {noreply, X}.
handle_call(_, _From, X) -> {reply, X, X}.

confirm(TID) -> gen_server:cast(?MODULE, {confirm, TID}).
trade(Trade) -> gen_server:cast(?MODULE, {trade, Trade}).
confirm_all() -> gen_server:cast(?MODULE, {confirm_all}).
stale_refunds() -> gen_server:cast(?MODULE, stale_refunds).

confirm_veo_cron() ->
    spawn(fun() -> cvc() end).
cvc() ->
    timer:sleep(config:confirm_tx_period(veo)),
    spawn(fun() -> unconfirmed_veo_feeder:confirm_all() end),
    cvc().

stale_trades_cron() ->
    spawn(fun() -> stc() end).
stc() ->
    timer:sleep(config:stale_trades_period(veo)),
    spawn(fun() -> stale_refunds() end),
    stc().
		  
