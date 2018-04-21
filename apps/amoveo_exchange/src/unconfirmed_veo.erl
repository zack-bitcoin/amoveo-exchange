%we are waiting for a confirmed veo tx to know that the customer has funded their side of the trade.

-module(unconfirmed_veo).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 read/1, trade/1, keys/0,
	 confirm/1, %attempts to confirm a single trade.
	 test/0]).
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
    {noreply, X2};
handle_cast({erase, TID}, X) -> 
    Y = dict:erase(TID, X),
    {noreply, Y};
handle_cast(_, X) -> {noreply, X}.
handle_call(keys, _From, X) -> 
    K = dict:fetch_keys(X),
    {reply, K, X};
handle_call({read, TID}, _From, X) -> 
    Y = dict:find(TID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(TID) ->
    gen_server:call(?MODULE, {read, TID}).
keys() ->
    gen_server:call(?MODULE, keys).
trade(Trade) ->%adds a new trade to the gen_server's memory.
    T = 2,
    unconfirmed_sell_veo = 
	id_lookup:number_to_type(T),
    Trade2 = Trade#trade{type = T},%convert trade to type "uncomfirmed_sell_veo
    gen_server:cast(?MODULE, {trade, Trade2}).
confirm(TID) ->
    Fee = config:fee(veo),
    {ok, Trade} = read(TID),
    VA = Trade#trade.veo_address,
    TA = Trade#trade.veo_amount + Fee,
    B = balance_veo:read(VA),
    if
	(B < TA) -> ok;
	true -> 
	    id_lookup:confirm(TID),
	    balance_veo:reduce(TA, VA),
	    T = 4,
	    unmatched_sell_veo = id_lookup:number_to_type(T),
	    Trade2 = Trade#trade{type = T},%change to type unmatched_buy_veo
	    order_book:trade(Trade2),
	    io:fwrite("removing trade\n"),
	    gen_server:cast(?MODULE, {erase, TID})
%remove(TID)
    end.

test() ->
    balance_veo:sync(),
    timer:sleep(300),
    unconfirmed_veo_feeder:confirm_all(),
    timer:sleep(300),
    VA = base64:decode(<<"BGRv3asifl1g/nACvsJoJiB1UiKU7Ll8O1jN/VD2l/rV95aRPrMm1cfV1917dxXVERzaaBGYtsGB5ET+4aYz7ws=">>),
    TID = crypto:strong_rand_bytes(32),
    Trade = #trade{type = 2, veo_address = VA, bitcoin_address = <<>>, veo_amount = 500000, bitcoin_amount = 10000, time_limit = 1000, id = TID},
    trade(Trade),
    timer:sleep(300),
    {ok, Trade} = read(TID),
    10000000 = balance_veo:read(VA),
    confirm(TID),
    2500000 = balance_veo:read(VA),
    success.
    
