-module(utils).
-compile(export_all).

read_file(LOC) -> 
    case file:read_file(LOC) of
	{error, _} -> "";
	{ok, X} -> binary_to_term(X)
    end.
save(X, LOC) -> file:write_file(LOC, term_to_binary(X)).
init(Default, LOC) ->
    X = read_file(LOC),
    Ka = if
	     X == "" -> 
		 Y = Default,
		 save(Y, LOC),
		 Y;
	     true -> X
	 end,
    {ok, Ka}.
   
electrum() -> 
    "/Applications/Electrum.app/Contents/MacOS/Electrum".
bitcoin(Command) ->
    Electrum = "http://localhost:8666",
    %Example = <<"{ \"id\": 17, \"method\": \"blockchain.estimatefee\", \"params\": [ 6 ] }">>,
    {ok, {{_, 200, _}, _, R} = httpc:request(post, {Electrum, [], "application/octet-stream", Command}, [{timeout, 3000}], []),
     R.
    
bitcoin_old(Command) ->
    C = "bitcoin-cli " ++ Command ++ " > temp",
    os:cmd(C),
    timer:sleep(200),
    {ok, F} = file:read_file("temp"),
    io:fwrite("binary json is "),
    io:fwrite(F),
    io:fwrite("\n"),
    F.
new_address(bitcoin) ->%working here.
    X = bitcoin("getunusedaddress").

%lists:reverse(tl(lists:reverse(binary_to_list(X)))).

%getreceivedbyaddress "address" ( minconf )

%listreceivedbyaddress ( minconf ) include_empty
%listreceivedbyaddress 0 true %lists all addresses
address_received(bitcoin, Address) ->
    C = <<<<"{ \"id\": 1, \"method\":\"blockchain.address.get_balance\", \"params\":[">>/binary, Address/binary, <<"] }">>/binary>>,
    X = bitcoin(C),
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
height(veo) -> 
    {ok, X} = talker:talk({height, 1}),
    max(0, X - config:confirmations()).

spend_from(veo, Tx) -> element(2, Tx).
spend_to(veo, Tx) -> element(5, Tx).
spend_amount(veo, Tx) -> element(6, Tx).
log(Name, Data) ->
    file:write_file(Name, Data, [append]).
 
spend(Type, To, Amount) -> 
    spawn(fun() -> spend2(Type, To, Amount) end).
spend2(veo, To, Amount) -> 
    S = "veo, " ++ To ++", " ++ integer_to_list(Amount) ++"\n",
    log("veo_payments.db", S),
    ok;
spend2(bitcoin, To, Amount) ->
    S = "btc, " ++ To ++", " ++ integer_to_list(Amount) ++"\n",
    log("btc_payments.db", S),
    ok.
    

bitcoin_test() ->
%[519291,"3JJCopJuEhAJreS4HDdxS2F2ZgZnubNfGh",<<>>]
    H = height(bitcoin),
    A = new_address(bitcoin),
    [H,
     A,
     address_received(bitcoin, A, 0)].

