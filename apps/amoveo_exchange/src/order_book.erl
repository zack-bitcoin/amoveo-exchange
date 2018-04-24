-module(order_book).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 trade/1, read/2, batch_cron/0, check/0,
	 test/0
	]).
-record(order, {trade, price}).
-include("records.hrl").
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({buy_veo, Trade}, _) -> 
    X = order_book_data:read(),
    X2 = X#ob{buy_veo = internal_trade(Trade, X#ob.buy_veo)},
    order_book_data:write(X2),
    {noreply, []};
handle_cast({sell_veo, Trade}, _) -> 
    X = order_book_data:read(),
    X2 = X#ob{sell_veo = internal_trade(Trade, X#ob.sell_veo)},
    order_book_data:write(X2),
    {noreply, []};
handle_cast(batch, _) ->
    X = order_book_data:read(),
    X2 = internal_batch(X#ob.buy_veo, X#ob.sell_veo, [], [], 0, 0),
    order_book_data:write(X2),
    {noreply, []};
handle_cast(_, X) -> {noreply, X}.
handle_call(check, _From, _) -> 
    X = order_book_data:read(),
    {reply, X, []};
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
	    
batch_cron() ->
    spawn(fun() -> batch_cron2() end).
batch_cron2() ->
    timer:sleep(config:batch_period() * 1000),
    batch().
batch() ->
    gen_server:cast(?MODULE, batch).

%%% internal functions
price(Trade) ->
    case Trade#trade.type of
	4 -> %sell veo
	    Trade#trade.veo_amount /
		Trade#trade.bitcoin_amount;
	3 -> %buy veo
	    Trade#trade.bitcoin_amount / 
		Trade#trade.veo_amount
    end.
    
internal_trade(Trade, L) ->
    %insert sort from paying high price, to paying a low price.
    Price = price(Trade),
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
ib_done(Buys, Sells, MB, MS, BA, SA) ->
    payout(MB, MS, BA, SA),
    #ob{buy_veo = Buys, sell_veo = Sells}.
internal_batch([], Sells, MB, MS, BA, SA) -> 
    ib_done([], Sells, MB, MS, BA, SA);
internal_batch(Buys, [], MB, MS, BA, SA) -> 
    ib_done(Buys, [], MB, MS, BA, SA);
internal_batch([B|BT], [S|ST], MB, MS, BA, SA) ->
    P1 = B#order.price,
    P2 = S#order.price,
    Bool = ((P1 * P2) > 1),
    if
	Bool ->
	    {B2,S2,MB2,MS2,MBA,MSA} = internal_batch2(B, S),
	    internal_batch(B2 ++ BT, S2 ++ ST, [MB2|MB], [MS2|MS], BA+MBA, SA+MSA);
	true -> ib_done([B|BT], [S|ST], MB, MS, BA, SA)
    end.
internal_batch2(Buy, Sell) ->
    BT = Buy#order.trade,
    ST = Sell#order.trade,
    BTV = BT#trade.veo_amount,
    STV = ST#trade.veo_amount,
    BTB = BT#trade.bitcoin_amount,
    STB = ST#trade.bitcoin_amount,
    BuyAmount0 = BTB * Sell#order.price,
    SellAmount0 = ST#trade.veo_amount,
    if
	BuyAmount0 > SellAmount0 ->
	    io:fwrite("match sell\n"),
	    BMV = STV,
	    BMB = BTB * BMV div BTV,%(bitcoin spent) * (portion veo matched)
	    BuyLeft0 = BT#trade{veo_amount = BTV - BMV,
				bitcoin_amount = BTB - BMB},
	    BuyMatched0 = BT#trade{veo_amount = BMV,
				   bitcoin_amount = BMB},
	    {[BuyLeft0], [], BuyMatched0, Sell#order.trade, BMB, STV};
	BuyAmount0 == SellAmount0 ->
	    io:fwrite("match both\n"),
	    {[], [], Buy, Sell, BTB, SellAmount0};
	BuyAmount0 < SellAmount0 ->
	    io:fwrite("match buy\n"),
	    SMB = BTB,
	    SMV = STV * SMB div STB,%(veo spent) * (potion bitcoin matched)
	    SellLeft0 = ST#trade{bitcoin_amount = STB - SMB,
				 veo_amount = STV - SMV},
	    SellMatched0 = ST#trade{bitcoin_amount = SMB,
				    veo_amount = SMV},
	    {[], [SellLeft0], SellMatched0, Buy#order.trade, BTB, SMV}
	end.
payout(MatchBuys, MatchSells, BA, SA) -> 
    ok = payout_buys(MatchBuys, BA, SA),
    ok = payout_sells(MatchSells, BA, SA).
payout_sells([], _, _) -> ok;
payout_sells(_, 0, _) -> error;
payout_sells(_, _, 0) -> error;
payout_sells([H|T], BA, SA) ->
    V = H#order.trade#trade.veo_amount,
    B = V * BA div SA,
    io:fwrite("spend bitcoin: "),
    io:fwrite(integer_to_list(B)),
    io:fwrite(" to: "),
    io:fwrite(H#order.trade#trade.bitcoin_address),
    io:fwrite("\n"),
    payout_sells(T, BA, SA).
payout_buys([], _, _) -> ok;
payout_buys(_, 0, _) -> error;
payout_buys(_, _, 0) -> error;
payout_buys([H|T], BA, SA) ->
    B = H#order.trade#trade.bitcoin_amount,
    V = B * SA div BA,
    io:fwrite("spend veo: "),
    io:fwrite(integer_to_list(V)),
    io:fwrite(" to: "),
    io:fwrite(H#order.trade#trade.veo_address),
    io:fwrite("\n"),
    payout_buys(T, BA, SA).
    
	    
	    
test() ->
    VA1 = "va1",
    VA2 = "va2",
    BA1 = "ba1",
    BA2 = "ba2",
    BuyVeoType = 3,
    SellVeoType = 4,
    trade(#trade{type = BuyVeoType, veo_address = VA1, bitcoin_address = BA1, veo_amount = 1000, bitcoin_amount = 5}),
    trade(#trade{type = BuyVeoType, veo_address = VA1, bitcoin_address = BA1, veo_amount = 1000, bitcoin_amount = 10}),
    trade(#trade{type = SellVeoType, veo_address = VA2, bitcoin_address = BA2, veo_amount = 1100, bitcoin_amount = 10}),
    trade(#trade{type = SellVeoType, veo_address = VA2, bitcoin_address = BA2, veo_amount = 500, bitcoin_amount = 10}),
    batch(),
    check().
