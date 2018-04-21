
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
bitcoin_json(Command) ->
    bitcoin_json(Command, []).
bitcoin_json(Command, Params) when 
  (is_list(Params) and is_binary(Command)) ->
    {[{<<"jsonrpc">>,<<"1.0">>},
      {<<"id">>,<<"amoveo_exchange">>},
      {<<"method">>,Command},
      {<<"params">>,Params}]}.

bitcoin(Command, Params) ->
    J = bitcoin_json(Command, Params),
    S = binary_to_list(jiffy:encode(J)),
    C = "curl --user user --data-binary '" ++ S ++ "' -H 'content-type: text/plain;' http://127.0.0.1:8332/ > temp",
    io:fwrite("shell command: "),
    io:fwrite(C),
    io:fwrite("\n"),
    file:write_file("temp.sh", C),
    os:cmd("sh temp.sh"),
    timer:sleep(200),
    {ok, F} = file:read_file("temp"),
    io:fwrite("binary json is "),
    io:fwrite(F),
    io:fwrite("\n"),
    %F2 = jiffy:decode(F),
    %F2.
    F.
new_address(bitcoin) ->
    X = bitcoin(<<"getnewaddress">>, []),
    X.

message_frequency() -> 1.
trade_frequency() -> 0.2.
block_txs(N) ->
    {ok, B} = talker:talk({block, 1, N}),
    B.
block_txs(bitcoin, N) ->
% lookup txs from one block by height = getblock(getblockhash(height))
    F = bitcoin(<<"getblockhash">>, [N]),
    F.
    
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
    X = bitcoin(<<"getblockcount">>, []),
    X;
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
    [height(bitcoin),
     new_address(bitcoin),
     block_txs(bitcoin, 400000)].
