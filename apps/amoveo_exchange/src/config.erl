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
pubkey() -> 
    {ok, P} = talker:talk({pubkey}),
    base64:decode(P).
pubkey_bad() -> 
    TM = mode(),
    Q = case TM of 
	    test -> <<"BGRv3asifl1g/nACvsJoJiB1UiKU7Ll8O1jN/VD2l/rV95aRPrMm1cfV1917dxXVERzaaBGYtsGB5ET+4aYz7ws=">>;
	    _ ->
		{ok, P} = talker:talk({pubkey}),
		P
	end,
    base64:decode(Q).
confirmations() -> 
    TM = mode(),
    case TM of
	test -> 2;
	_ -> 30
    end.
height(veo) -> 
    {ok, X} = talker:talk({height, 1}),
    max(0, X - confirmations()).

spend_from(veo, Tx) -> element(2, Tx).
spend_to(veo, Tx) -> element(5, Tx).
spend_amount(veo, Tx) -> element(6, Tx).
   
fee(veo) -> 7000000;
fee(bitcoin) -> 70000.
