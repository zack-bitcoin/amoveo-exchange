-module(test).
-export([test/0]).

test() ->
    S = success,
    S = balance_veo:test(),
    S = unconfirmed_veo:test(),
    S = config:test(),
    order_book:test(),
    S.
    
