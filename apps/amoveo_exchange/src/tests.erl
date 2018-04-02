-module(tests).
-export([doit/0]).

doit() ->
    S = success,
    S = unconfirmed_veo:test(),
    S.
