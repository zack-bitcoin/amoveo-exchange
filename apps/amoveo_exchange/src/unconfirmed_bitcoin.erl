%we are waiting for a confirmed tx that the customer has funded their trade.

-module(unconfirmed_bitcoin).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, trade/2]).
-include("records.hrl").
init(ok) -> {ok, dict:new()}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({trade, Trade, TID}, X) -> 
    
    id_lookup:add_veo(TID),
    {noreply, X};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, TID}, _From, X) -> 
    Y = dict:find(TID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(TID) ->
    gen_server:call(?MODULE, {read, TID}).
trade(Trade, TID) ->
    gen_server:cast(?MODULE, {trade, Trade, TID}).
