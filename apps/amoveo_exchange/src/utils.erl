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
    Electrum = "http://localhost:8666",
    {ok, {{_, 200, _}, _, R}} = httpc:request(post, {Electrum, [], "application/octet-stream", Command}, [{timeout, 3000}], []),
     R.
   
 
block_txs(N) ->
    {ok, B} = talker:talk({block, 1, N}),
    B.
pubkey() -> %gets your veo pubkey.
    {ok, P} = talker:talk({pubkey}),
    base64:decode(P).

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
    ok.
    


