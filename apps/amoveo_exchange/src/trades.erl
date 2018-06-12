-module(trades).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	cron/0,read/1,add/1]).
-record(trade, {veo_from, start_height, bitcoin_address, veo_to, start_time, time_limit, veo_amount, bitcoin_amount, initial_bitcoin_balance}).
-define(LOC, "trades.db").
init(ok) -> 
    process_flag(trap_exit, true),
    utils:init(dict:new(), ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(?LOC, X),
    io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(update, X) -> 
    Keys = dict:fetch_keys(X),
    X2 = update_internal(Keys, X),
    {noreply, X};
handle_cast(_, X) -> {noreply, X}.
handle_call({add, {From, StartHeight, BitcoinAddress, VeoTo, TimeLimit, VeoAmount, BitcoinAmount}}, _, X) ->
    {X3, Result} 
	= case dict:find(BitcoinAddress, X) of
	      error ->
		  IB = utils:total_received_bitcoin(BitcoinAddress),
		  T = #trade{veo_from = From, start_height = StartHeight, bitcoin_address = BitcoinAddress, veo_to = VeoTo, start_time = erlang:timestamp(), time_limit = TimeLimit, veo_amount = VeoAmount, bitcoin_amount = BitcoinAmount, initial_bitcoin_balance = IB},
		  X2 = dict:store(BitcoinAddress, T, X),
		  {X2, <<"trade with that bitcoin address already exists">>};
	      {ok, _} -> {X, 0}
	 end,
    {reply, Result, X3};
handle_call({read, BitcoinAddress}, _, X) ->
    Y = dict:find(BitcoinAddress, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(X) -> gen_server:call(?MODULE, {read, X}).
add(X) -> gen_server:call(?MODULE, {add, X}).
    
update() -> gen_server:cast(?MODULE, update).
update_internal([], Dict) -> Dict;
update_internal([Key|T], Dict) ->
    K = dict:fetch(Key),
    GA = K#trade.initial_bitcoin_balance + K#trade.bitcoin_amount,
    CA = utils:bitcoin_balance(K#trade.bitcoin_address),
    TL = K#trade.time_limit,
    ST = K#trade.start_time,
    Seconds = timer:now_diff(erlang:timestamp(), ST) div 1000000,
    VF = K#trade.veo_from,
    VA = K#trade.veo_amount,
    Dict2 = if
		GA =< CA -> 
		    %check if any trade has been funded with bitcoin. if it has, then forward those veo to the different account, and delete the trade.
		    accounts:transfer_locked(VF, K#trade.veo_to, VA),
		    dict:erase(Key, Dict);
		Seconds > TL ->
		    %check if any trade is expired. if it is, delete it and move the money in that account from locked to veo.
		    accounts:unlock(VF, VA),
		    dict:erase(Key, Dict);
		true -> Dict
	    end,
    update_internal(T, Dict2).

cron() ->
    spawn(fun() -> cron2() end).
cron2() ->
    timer:sleep(40000),%every 40 seconds.
    update(),
    cron2().
