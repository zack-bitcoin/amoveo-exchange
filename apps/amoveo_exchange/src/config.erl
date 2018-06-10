-module(config).
-compile(export_all).

mode() -> test.
%mode() -> production.
cold(veo) -> %this is the veo address where we send our veo profit.
    <<"BGH+3P768A9cSNR3GLSRXgsokSL/Jdbm+rOJogbgiPxq8M+J2R4nVxZ+Hj6WdI4rMsq6nPzkMh77WGBCMx89HUM=">>.
message_frequency() -> 1.%this is how often each ip address can check the status of a trade.
trade_frequency() -> 0.2.%this is how often each ip address can put trades into the order book.
market_data_frequency() -> 3.%this is how often each ip address can look up the open orders from the order book.
confirmations() -> %this is how many confirmations we wait after a tx is included in a block until we accept the payment as spent.
    TM = mode(),
    case TM of
	test -> 2;
	_ -> 6
    end.
fee(veo) -> 7000000.%in satoshis
make_id() -> crypto:strong_rand_bytes(32).
sync_block_period(veo) -> 40000.%in miliseconds.
confirm_tx_period(veo) -> 40000.%in miliseconds.
bitcoin_height_check_delay() -> 20.%seconds
batch_period() -> 1800.%in seconds
scan_history() -> 100.%when turning on the node with empty databases, how far back in the past do you include transactions from?
full_node() -> 
    TM = mode(),
    case TM of
	test -> "http://localhost:3011/";
	_ -> "http://localhost:8081/"
    end.
id_lookup_file() -> "id_lookup.db".
file(X) -> atom_to_list(X) ++ ".db".
trade_time_limit() -> 12 * 60 * 60.%12 hours in seconds
profit_check_period(veo) ->
    5000.
profit_limit(veo) ->% in satoshi
    20000000.%0.2 veo
%fee is about 152000
    
stale_trades_period(veo) ->%how often in miliseconds to check if any of the unconfirmed trades, have run out of time and gone stale.
    10000;
stale_trades_period(bitcoin) ->%how often in miliseconds to check if any of the unconfirmed trades, have run out of time and gone stale.
    10000.
order_book_stale_period() ->    
    10000.%in miliseconds
min_trade_time() ->
    60*60.%in seconds
max_trade_time() ->
    12*60*60.%in seconds
deposit_fee() ->
    70000.
%from(Tx) -> element(2, Tx).
%amount(Tx) -> element(6, Tx).
