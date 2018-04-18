-module(config).
-compile(export_all).

mode() -> test.
full_node() -> 
    TM = mode(),
    case TM of
	test -> "http://localhost:3011/";
	_ -> "http://localhost:8081/"
    end.
message_frequency() -> 1.
trade_frequency() -> 0.2.
block_txs(N) ->
    {ok, B} = talker:talk({block, 1, N}),
    B.
scan_history() -> 100.%when turning on the node with empty databases, how far back in the past do you include transactions from?
pubkey() -> 
    {ok, P} = talker:talk({pubkey}),
    base64:decode(P).
confirmations() -> 
    TM = mode(),
    case TM of
	test -> 2;
	_ -> 30
    end.
height(bitcoin) -> 0.

height(veo) -> 
    {ok, X} = talker:talk({height, 1}),
    max(0, X - confirmations()).

spend_from(veo, Tx) -> element(2, Tx).
spend_to(veo, Tx) -> element(5, Tx).
spend_amount(veo, Tx) -> element(6, Tx).
   
fee(veo) -> 7000000;
fee(bitcoin) -> 70000.
make_id() -> crypto:strong_rand_bytes(32).

sync_block_period(veo) -> 40000.%in miliseconds.
confirm_tx_period(veo) -> 40000.%in miliseconds.
    
