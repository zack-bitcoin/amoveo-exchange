%we are waiting for a confirmed tx that the customer has funded their trade.

-module(unconfirmed_bitcoin).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, trade/1, confirm/1, keys/0]).
-include("records.hrl").
init(ok) -> {ok, dict:new()}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({trade, Trade}, X) -> 
    TID = Trade#trade.id,
    X2 = dict:store(TID, Trade, X),
    id_lookup:add_veo(TID),
    {noreply, X};
handle_cast({erase, TID}, X) -> 
    Y = dict:erase(TID, X),
    {noreply, Y};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, TID}, _From, X) -> 
    Y = dict:find(TID, X),
    {reply, Y, X};
handle_call(keys, _From, X) -> 
    {reply, dict:fetch_keys(X), X};
handle_call(_, _From, X) -> {reply, X, X}.

keys() ->
    gen_server:call(?MODULE, keys).
trade(Trade) ->
    T = 1,
    unconfirmed_buy_veo = 
	id_lookup:number_to_type(T),
    Trade2 = Trade#trade{type = T},%convert trade to type "uncomfirmed_buy_veo
    gen_server:cast(?MODULE, {trade, Trade2}).
read(TID) ->
    gen_server:call(?MODULE, {read, TID}).
confirm(TID) ->
    Fee = config:fee(bitcoin),
    {ok, Trade} = read(TID),
    VA = Trade#trade.server_bitcoin_address,
    TA = Trade#trade.bitcoin_amount + Fee,
    B = balance_bitcoin:read(VA),
    if
	(B < TA) -> ok;
	true -> 
	    id_lookup:confirm(TID),
	    balance_bitcoin:reduce(TA, VA),
	    T = 4,
	    unmatched_buy_veo = id_lookup:number_to_type(T),
	    Trade2 = Trade#trade{type = T},%change to type unmatched_buy_veo
	    order_book:trade(Trade2),
	    io:fwrite("removing trade\n"),
	    gen_server:cast(?MODULE, {erase, TID})
    end.
%remove(TID)
    
