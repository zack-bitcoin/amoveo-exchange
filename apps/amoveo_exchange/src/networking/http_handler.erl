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
    true = 0 < BitcoinAmount,
    true = 0 < VeoAmount,
    true = is_integer(BitcoinAmount),
    true = is_integer(VeoAmount),
    ok = trade_limit:doit(IP),
    true = is_integer(TimeLimit),
    %time limit is a number of seconds for how long to wait until the trade goes stale.
    true = TimeLimit > config:min_trade_time(),
    true = TimeLimit < config:max_trade_time(),
    {Type, NA} = case N of
	       2 -> {unconfirmed_buy_veo, 0};
	       1 -> {unconfirmed_sell_veo, 
		     utils:new_address(bitcoin)}
	   end,
    TID = config:make_id(),
    TimeLimit2 = {erlang:timestamp(), TimeLimit},
    Trade = #trade{type = Type, veo_address = CustomerVeoAddress, bitcoin_address = CustomerBitcoinAddress, veo_amount = VeoAmount, bitcoin_amount = BitcoinAmount, time_limit = TimeLimit2, id = TID, server_bitcoin_address = NA},
    Addr = case N of
	       2 -> unconfirmed_veo_feeder:trade(Trade),
		    ServerVeoAddress = utils:pubkey(),
		    ServerVeoAddress;
	       1 -> unconfirmed_bitcoin_feeder:trade(Trade),
		    NA
	   end,
    {ok, [Addr, TID]};
doit({exist, TID}, IP) -> %check the status of a trade
    {ok, 0};
doit({test}, _) ->
    {ok, <<"success 2">>};
doit({account, X}, _) ->
    {ok, Account} = accounts:get(X),
    {ok, Account};
doit(X, _) ->
    io:fwrite("http handler cannot handle this "),
    io:fwrite(packer:pack(X)),
    io:fwrite("\n"),
    {ok, <<"error">>}.
    
