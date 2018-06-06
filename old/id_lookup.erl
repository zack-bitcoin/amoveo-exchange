%This gen server is for looking up the status of any trade.
%once you know the status, then you know which gen_server it is located in.

-module(id_lookup).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, add_veo/1, add_bitcoin/1, confirm/1, finalize/1,
	number_to_type/1]).
-include("records.hrl").
-define(not_exist, <<"trade does not exist">>).
-define(wait_confirmations, <<"waiting for confirmations">>).
-define(wait_confirmations_sell, <<"waiting for confirmations to sell veo">>).
-define(in_order_book, <<"trade in order book">>).
-define(LOC, config:file(?MODULE)).
init(ok) -> 
    process_flag(trap_exit, true),
    utils:init(dict:new(), ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(X, ?LOC),
    io:format("id lookup died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({add_veo, ID}, X) -> 
    Y = dict:store(ID, 1, X),
    {noreply, Y};
handle_cast({add_bitcoin, ID}, X) -> 
    Y = dict:store(ID, 2, X),
    {noreply, Y};
handle_cast({confirm, ID}, X) -> 
    Y = dict:store(ID, 3, X),
    {noreply, Y};
handle_cast({finalize, ID}, X) -> 
    Y = dict:store(ID, 4, X),
    {noreply, Y};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, ID}, _From, X) -> 
    Y = dict:find(ID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

number_to_type(0) -> empty;
number_to_type(1) -> unconfirmed_buy_veo;
number_to_type(2) -> unconfirmed_sell_veo;
number_to_type(3) -> unmatched_buy_veo;
number_to_type(4) -> unmatched_sell_veo;
number_to_type(5) -> history.
id_to_type(ID) ->
    case gen_server:call(?MODULE, {read, ID}) of
	error -> 0;
	{ok, X} -> X
    end.
    
read(ID) -> 
    X = id_to_type(ID),
    case number_to_type(X) of
	empty -> [?not_exist];
	unconfirmed_sell_veo -> 
	    Fee = config:fee(veo),
	    {ok, Trade} = unconfirmed_veo:read(ID),
	    VA = Trade#trade.veo_address,
	    TA = Trade#trade.veo_amount + Fee,
	    B = balance_veo:read(VA),
	    [?wait_confirmations, B, TA, Trade];
	unconfirmed_buy_veo -> 
	    Fee = config:fee(bitcoin),
	    {ok, Trade} = unconfirmed_bitcoin:read(ID),
	    VA = Trade#trade.server_bitcoin_address,
	    TA = Trade#trade.veo_amount + Fee,
	    B = balance_veo:read(VA),
	    [?wait_confirmations_sell, B, TA, Trade];
	unmatched_buy_veo -> 
	    Trade = order_book:read(buy_veo, ID),
	    [?in_order_book, Trade];
	unmatched_sell_veo -> 
	    Trade = order_book:read(sell_veo, ID),
	    [?in_order_book, Trade];
	history -> 
	    Trade = trade_history:read(ID),
	    [<<"trade completed">>, Trade]
    end.
	    
add_veo(ID) -> 
    empty = number_to_type(id_to_type(ID)),
    gen_server:cast(?MODULE, {add_veo, ID}).
add_bitcoin(ID) -> 
    empty = number_to_type(id_to_type(ID)),
    gen_server:cast(?MODULE, {add_bitcoin, ID}).
confirm(ID) -> 
    X = number_to_type(id_to_type(ID)),
    ok = case X of
	     unconfirmed_buy_veo -> ok;
	     unconfirmed_sell_veo -> ok
	 end,
    gen_server:cast(?MODULE, {confirm, ID}).
finalize(ID) -> 
    X = number_to_type(id_to_type(ID)),
    ok = case X of
	     unmatched_buy_veo -> ok;
	     unmatched_sell_veo -> ok
	 end,
    gen_server:cast(?MODULE, {finalize, ID}).
    
    
