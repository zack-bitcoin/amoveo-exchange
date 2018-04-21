-module(order_book).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 trade/1, time_since_last_batch/0, read/2, batch/0,
	 check/0
	]).
-record(ob, {buy_veo = [], sell_veo = [], last_match_time}).
-record(order, {trade, price}).
-include("records.hrl").
-define(File, "order_book.db").
-define(Period, 1800).
initial_state() ->
    #ob{last_match_time = erlang:timestamp()}.
init(ok) ->
    A = case file:read_file(?File) of
	    {error, enoent} -> initial_state();
	    {ok, B} ->
		case B of
		    "" -> initial_state();
		    _ -> binary_to_term(B)
		end
	end,
    {ok, A}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({buy_veo, Trade}, X) -> 
    X2 = X#ob{buy_veo = internal_trade(Trade, X#ob.buy_veo)},
    {noreply, X2};
handle_cast({sell_veo, Trade}, X) -> 
    X2 = X#ob{sell_veo = internal_trade(Trade, X#ob.sell_veo)},
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call(check, _From, X) -> {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

trade(Trade) ->
    T = id_lookup:number_to_type(Trade#trade.type),
    case T of 
	unmatched_buy_veo ->
	    gen_server:cast(?MODULE, {buy_veo, Trade});
	unmatched_sell_veo ->
	    gen_server:cast(?MODULE, {sell_veo, Trade})
    end.

check() ->
    gen_server:call(?MODULE, check).
time_since_last_batch() ->
    D = check(),
    Delta = timer:now_diff(erlang:timestamp(), D#ob.last_match_time),
    %?Period - (Delta / 1000000).%in seconds.
    Delta / 1000000.%in seconds.
    
read(buy_veo, TID) -> 
    X = check(),
    Buys = X#ob.buy_veo,
    read2(TID, Buys);
read(sell_veo, TID) -> 
    X = check(),
    Sells = X#ob.sell_veo,
    read2(TID, Sells).
read2(TID, [H|T]) ->
    TID2 = H#order.trade#trade.id,
    if 
	TID == TID2 -> H#order.trade;
	true -> read2(TID, T)
    end.
	    
batch() ->
    %check if enough time has passed.
    X = time_since_last_batch(),
    Y = ?Period - X,
    if
	Y < 0 -> %do a batch
	    ok;
	true -> ok
    end.


%%% internal functions

internal_trade(Trade, L) ->
    %insert sort from paying high price, to paying a low price.
    Price = case Trade#trade.type of
		3 -> %buy veo
		    Trade#trade.veo_amount /
			Trade#trade.bitcoin_amount;
		4 -> %sell veo
		    Trade#trade.bitcoin_amount / 
			Trade#trade.veo_amount
	    end,
    Order = #order{trade = Trade, price = Price},
    internal_trade2(Order, L).
internal_trade2(Order, []) -> [Order];
internal_trade2(NewOrder, [Order|T]) ->
    P = Order#order.price,
    P2 = NewOrder#order.price,
    if
	P2 > P -> [NewOrder|[Order|T]];
	true -> [Order|internal_trade2(NewOrder, T)]
    end.
	    
	    
