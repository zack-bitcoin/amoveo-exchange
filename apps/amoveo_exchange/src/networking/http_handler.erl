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
doit({trade, SR}, IP) ->
    io:fwrite("submitting a trade\n"),
    %ok = trade_limit:doit(IP),
    R = element(2, SR),
    {29, Pubkey, Height, BitcoinAddress, VeoTo, TimeLimit, VeoAmount, BitcoinAmount, ServerPubkey} = R,
    ServerPubkey = base64:encode(utils:pubkey()),
    true = is_integer(VeoAmount),
    true = VeoAmount > 0,
    true = is_integer(BitcoinAmount),
    true = BitcoinAmount > 0,
    true = is_integer(Height),
    true = is_integer(TimeLimit),
    true = TimeLimit > config:min_trade_time(),
    true = TimeLimit < config:max_trade_time(),
    true = is_binary(BitcoinAddress),
    true = is_binary(VeoTo),
    true = is_binary(Pubkey),
    34 = size(BitcoinAddress),
    65 = size(VeoTo),
    65 = size(Pubkey),
    {ok, NodeHeight} = packer:unpack(talker:talk_helper({height}, config:full_node(), 10)),
    true = NodeHeight < Height + 3,
    true = NodeHeight > Height - 1,
    Sig = element(3, SR),
    true = sign:verify_sig(R, Sig, Pubkey),
    io:fwrite("submitting a trade 2\n"),
    case accounts:lock(Pubkey, VeoAmount, Height, BitcoinAddress) of
	success -> 
	    io:fwrite("account locked\n"),
	    Result = trades:add({Pubkey, Height, BitcoinAddress, VeoTo, TimeLimit, VeoAmount, BitcoinAmount}),
	    {ok, Result};
	Reason -> 
	    io:fwrite("trade failed because \n"),
	    io:fwrite(Reason),
	    io:fwrite("\n"),
	    {ok, Reason}
    end;
doit({exist, BitcoinAddress}, _) -> %check the status of a trade
    R = case trades:read(BitcoinAddress) of
	    error -> <<"does not exist">>;
	    {ok, X} -> X
	end,
    {ok, R};
doit({test}, _) ->
    {ok, <<"success 2">>};
doit({account, X}, _) ->
    case accounts:get(X) of
	{ok, A} -> {ok, A};
	error -> {ok, 0}
    end;
doit({height}, _) ->
    {ok, NodeHeight} = packer:unpack(talker:talk_helper({height}, config:full_node(), 10)),
    {ok, NodeHeight};
doit({pubkey}, _) ->
    {ok, NodePub} = packer:unpack(talker:talk_helper({pubkey}, config:full_node(), 10)),
    {ok, NodePub};
doit({spend, SR}, _) ->
    R = element(2, SR),
    {28, Pubkey, Height} = R,
    {ok, NodeHeight} = packer:unpack(talker:talk_helper({height}, config:full_node(), 10)),
    true = NodeHeight < Height + 3,
    true = NodeHeight > Height - 1,
    Sig = element(3, SR),
    true = sign:verify_sig(R, Sig, Pubkey),
    accounts:withdrawal(Pubkey),
    {ok, 0};
doit(X, _) ->
    io:fwrite("http handler cannot handle this "),
    io:fwrite(packer:pack(X)),
    io:fwrite("\n"),
    {ok, <<"error">>}.
    
