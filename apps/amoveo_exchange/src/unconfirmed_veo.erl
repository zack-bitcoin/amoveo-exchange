%we are waiting for a confirmed veo tx to know that the customer has funded their side of the trade.

-module(unconfirmed_veo).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, trade/2, remove/1, test/0]).
-include("records.hrl").
init(ok) -> {ok, dict:new()}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({partial_match, TID, BA, VA}, X) -> 
    A = dict:find(TID, X),
    A#trade{bitcoin_amount = A#trade.bitcoin_amount - BA, 
	    veo_amount = A#trade.veo_amount - VA},
    X2 = dict:store(TID, A, X),
    {noreply, X2};
handle_cast({trade, Trade, TID}, X) -> 
    X2 = dict:store(TID, Trade, X),
    id_lookup:add_veo(TID),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({erase, TID}, _From, X) -> 
    Y = dict:erase(TID, X),
    {reply, Y, X};
handle_call({read, TID}, _From, X) -> 
    Y = dict:find(TID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(TID) ->
    gen_server:call(?MODULE, {read, TID}).
trade(Trade, TID) ->
    gen_server:cast(?MODULE, {trade, Trade, TID}).
partial_match(TID, Amount) ->
    gen_server:cast(?MODULE, {partial_match, TID, Amount}).
remove(TID) ->
    gen_server:cast(?MODULE, {erase, TID}).

verify_confirmed(TID) ->
    %talker:talk to find out if it is confirmed
    Trade = read(TID),
    Height = config:height(),
    H = history_veo:history(100, Height),
    VA = Trade#trade.veo_address,
    B = find_load(VA, H),
    if
	B == [] -> false;
	true -> ok
    end.
find_load(VA, []) -> [];
find_load(VA, [H|T]) ->
    VB = config:veo_spend_from(H),
    if
	VA == VB -> [H|find_load(VA, T)];
	true -> find_load(VA, T)
    end.
	    
confirm(TID) ->
    B = verify_confirmed(TID),
    case B of
	true ->
	    id_lookup:confirm(TID),
	    remove(TID);
	false -> ok
    end.

test() ->
    TID = crypto:strong_rand_bytes(32),
    Trade = #trade{},
    trade(Trade, TID),
    {ok, Trade} = read(TID),
    remove(TID),
    success.
    
