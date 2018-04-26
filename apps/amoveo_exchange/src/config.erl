-module(config).
-compile(export_all).

cold_bitcoin() ->
    <<>>.%this is the bitcoin address where we send our bitcoin profit.
cold_veo() ->
    <<>>.%this is the veo address where we send our veo profit.
message_frequency() -> 1.%this is how often each ip address can check the status of a trade.
trade_frequency() -> 0.2.%this is how often each ip address can put trades into the order book.
confirmations() -> %this is how many confirmations we wait after a tx is included in a block until we accept the payment as spent.
    TM = mode(),
    case TM of
	test -> 2;
	_ -> 30
    end.
fee(veo) -> 7000000;%in satoshis
fee(bitcoin) -> 70000.%in satoshis
make_id() -> crypto:strong_rand_bytes(32).
sync_block_period(veo) -> 40000.%in miliseconds.
confirm_tx_period(veo) -> 40000;%in miliseconds.
confirm_tx_period(bitcoin) -> 40000.%in miliseconds.
bitcoin_height_check_delay() -> 20.%seconds
batch_period() -> 1800.%in seconds
scan_history() -> 100.%when turning on the node with empty databases, how far back in the past do you include transactions from?
mode() -> test.
%mode() -> production.
full_node() -> 
    TM = mode(),
    case TM of
	test -> "http://localhost:3011/";
	_ -> "http://localhost:8081/"
    end.
id_lookup_file() -> "id_lookup.db".
file(X) -> atom_to_list(X) ++ ".db".
