-module(utils).
-export([pubkey/0]).

pubkey() -> 
    {ok, P} = talker:talk({pubkey}),
    P.
