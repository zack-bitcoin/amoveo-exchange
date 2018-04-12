-module(config).
-compile(export_all).

full_node() -> "http://localhost:8081/".
message_frequency() -> 1.
trade_frequency() -> 0.2.
pubkey() -> 
    {ok, P} = talker:talk({pubkey}),
    P.
confirmations() -> 10.
height(veo) -> talker:talk({height, 1}) - confirmations().

spend_from(veo, Tx) -> element(2, Tx).
spend_to(veo, Tx) -> element(5, Tx).
spend_amount(veo) -> element(6, Tx).
   
fee(veo) -> 500000000.
fee(bitcoin) -> 0 0007 0000.
