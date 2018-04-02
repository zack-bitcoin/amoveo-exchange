-module(config).
-compile(export_all).

full_node() -> "http://localhost:8081/".
message_frequency() -> 1.
trade_frequency() -> 0.2.
pubkey() -> 
    {ok, P} = talker:talk({pubkey}),
    P.
height() ->
    talker:talk({height, 1}).

veo_spend_from(Tx) -> element(2, Tx).
veo_spend_to(Tx) -> element(5, Tx).
   
    
