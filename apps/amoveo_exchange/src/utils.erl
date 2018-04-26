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
    max(0, X - config:confirmations()).

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

