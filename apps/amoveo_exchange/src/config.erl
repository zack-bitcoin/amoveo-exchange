
-module(config).
-compile(export_all).

%mode() -> test.
mode() -> production.
full_node() -> 
    TM = mode(),
    case TM of
	test -> "http://localhost:3011/";
	_ -> "http://localhost:8081/"
    end.
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
    %jiffy:decode(X).
    lists:reverse(tl(lists:reverse(binary_to_list(X)))).

message_frequency() -> 1.
trade_frequency() -> 0.2.
block_txs(N) ->
    {ok, B} = talker:talk({block, 1, N}),
    B.
block_txs(bitcoin, N) ->
% lookup txs from one block by height = getblock(getblockhash(height))
    io:fwrite("block_txs 0\n"),
    F = bitcoin("getblockhash " ++ integer_to_list(N)),
% <<"000000000000000004ec466ce4732fe6f1ed1cddc2ed4b328fff5224276e3f6f\n">>]
    io:fwrite("block_txs 1\n"),
    %Y = jiffy:decode(F),
    io:fwrite("block_txs 2\n"),
    Y = lists:reverse(tl(lists:reverse(binary_to_list(F)))),
    G = bitcoin("getblock "++Y),
    io:fwrite("block_txs 3\n"),
    Txs = element(2, lists:nth(10, element(1, jiffy:decode(G)))),
    io:fwrite("block_txs 4\n"),
    Tx = hd(Txs),
    io:fwrite(Tx),
    io:fwrite("\n"),
    bitcoin("gettransaction " ++ Tx).
%Txs.
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

height(bitcoin) -> 
    X = bitcoin("getblockcount"),
   %<<"519291\n">>
    jiffy:decode(X);
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
    

bitcoin_test() ->
%[519291,"3JJCopJuEhAJreS4HDdxS2F2ZgZnubNfGh",<<>>]
    H = height(bitcoin),
    [H,
     new_address(bitcoin),
     block_txs(bitcoin, H-50)].
