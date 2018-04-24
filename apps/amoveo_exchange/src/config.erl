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
confirm_tx_period(veo) -> 40000.%in miliseconds.
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

%=========== everything below this line should be in a different module.


bitcoin(Command) ->
    C = "bitcoin-cli " ++ Command ++ " > temp",
    os:cmd(C),
    timer:sleep(200),
    {ok, F} = file:read_file("temp"),
    io:fwrite("binary json is "),
    io:fwrite(F),
    io:fwrite("\n"),
    F.
new_address(bitcoin) ->
    X = bitcoin("getnewaddress"),
    lists:reverse(tl(lists:reverse(binary_to_list(X)))).

%getreceivedbyaddress "address" ( minconf )

%listreceivedbyaddress ( minconf ) include_empty
%listreceivedbyaddress 0 true %lists all addresses
address_received(bitcoin, Address, Confirmations) ->
    X = bitcoin("getreceivedbyaddress \"" ++ Address ++ "\" " ++ integer_to_list(Confirmations)),
    jiffy:decode(X). % returns an integer
block_txs(N) ->
    {ok, B} = talker:talk({block, 1, N}),
    B.
pubkey() -> %gets your veo pubkey.
    {ok, P} = talker:talk({pubkey}),
    base64:decode(P).

height(bitcoin) -> 
    X = bitcoin("getblockcount"),
   %<<"519291\n">>
    jiffy:decode(X);
height(veo) -> %move this func to a different module
    {ok, X} = talker:talk({height, 1}),
    max(0, X - confirmations()).

spend_from(veo, Tx) -> element(2, Tx).
spend_to(veo, Tx) -> element(5, Tx).
spend_amount(veo, Tx) -> element(6, Tx).
   

bitcoin_test() ->
%[519291,"3JJCopJuEhAJreS4HDdxS2F2ZgZnubNfGh",<<>>]
    H = height(bitcoin),
    A = new_address(bitcoin),
    [H,
     A,
     address_received(bitcoin, A, 0)].

