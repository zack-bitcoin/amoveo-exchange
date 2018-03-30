-module(http_handler).
-export([init/3, handle/2, terminate/3, doit/1]).
%example: `curl -i -d '["test"]' http://localhost:8087`

init(_Type, Req, _Opts) -> {ok, Req, no_state}.
terminate(_Reason, _Req, _State) -> ok.
handle(Req, State) ->
    {ok, Data0, Req2} = cowboy_req:body(Req),
    {{IP, _}, Req3} = cowboy_req:peer(Req2),
    Data = packer:unpack(Data0),
    D0 = doit(Data),
    D = packer:pack(D0),
    Headers=[{<<"content-type">>,<<"application/octet-stream">>},
    {<<"Access-Control-Allow-Origin">>, <<"*">>}],
    {ok, Req4} = cowboy_req:reply(200, Headers, D, Req3),
    {ok, Req4, State}.

% add buy order, add sell order.
doit({bet, 1, CustomerVeoAddress, VeoAmount, BitcoinAmount, TimeLimit}) -> %buy veo
    %add it to the gen_server that waits for enough amoveo confirmations.
    %we should probably return a trade ID so the trade can be quickly looked up.
    {ok, [ServerBitcoinAddress, TID]};
doit({bet, 2, CustomerVeoAddress, CustomerBitcoinAddress, VeoAmount, BitcoinAmount, TimeLimit}) -> %sell veo
    %add it to the gen_server that waits for enough amoveo confirmations.
    %we should probably return a trade ID so the trade can be quickly looked up.
    {ok, [ServerVeoAddress, TID]};
doit({exist, TID}) -> %check the status of your order
    {ok, <<"success 1">>};
doit({test}) ->
    {ok, <<"success 2">>};
doit(X) ->
    io:fwrite("http handler cannot handle this "),
    io:fwrite(packer:pack(X)),
    io:fwrite("\n"),
    {ok, <<"error">>}.
    
