-module(http_handler).
-export([init/3, handle/2, terminate/3, doit/2]).
%example: `curl -i -d '["test"]' http://localhost:8087`

-include("records.hrl").
init(_Type, Req, _Opts) -> {ok, Req, no_state}.
terminate(_Reason, _Req, _State) -> ok.
handle(Req, State) ->
    {ok, Data0, Req2} = cowboy_req:body(Req),
    {{IP, _}, Req3} = cowboy_req:peer(Req2),
    Data = packer:unpack(Data0),
    D0 = doit(Data, IP),
    D = packer:pack(D0),
    Headers=[{<<"content-type">>,<<"application/octet-stream">>},
    {<<"Access-Control-Allow-Origin">>, <<"*">>}],
    {ok, Req4} = cowboy_req:reply(200, Headers, D, Req3),
    {ok, Req4, State}.

doit({bet, N, CustomerVeoAddress, CustomerBitcoinAddress, VeoAmount, BitcoinAmount, TimeLimit}, IP) -> %sell or buy veo.
    %add it to the gen_server that waits for enough confirmations.
    ok = trade_limit:doit(IP),
    TID = config:make_id(),
    Type = case N of
	       1 -> unconfirmed_buy_veo;
	       2 -> unconfirmed_sell_veo
	   end,
    Trade = #trade{type = Type, veo_address = CustomerVeoAddress, bitcoin_address = CustomerBitcoinAddress, veo_amount = VeoAmount, bitcoin_amount = BitcoinAmount, time_limit = TimeLimit, id = TID},
    Addr = case N of
	       1 -> unconfirmed_veo_feeder:trade(Trade),
		    ServerVeoAddress = config:pubkey(),
		    ServerVeoAddress;
	       2 -> unconfirmed_bitcoin:trade(Trade),
		    0%we need to return one of the server's bitcoin addresses here.
	   end,
    {ok, [Addr, TID]};
doit({exist, TID}, IP) -> %check the status of your order
    ok = message_limit:doit(IP),
    {ok, id_lookup:read(TID)};
doit({test}, _) ->
    {ok, <<"success 2">>};
doit(X, _) ->
    io:fwrite("http handler cannot handle this "),
    io:fwrite(packer:pack(X)),
    io:fwrite("\n"),
    {ok, <<"error">>}.
    
