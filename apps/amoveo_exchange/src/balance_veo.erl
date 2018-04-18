%this gen server should lazily remember how much money they have sent us, and the last height we checked how much they sent us.

-module(balance_veo).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 read/1, sync/0,
	 reduce/2,%reduces how many veo are controlled by this account.
	 test/0]).
-record(d, {height, dict}).
init(ok) -> 
    D = #d{height = max(0, config:height(veo) - config:scan_history()), 
	   dict = dict:new()},
    {ok, D}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({reduce, Amount, VA}, X) -> 
    Dict = X#d.dict,
    X2 = case dict:find(VA, Dict) of
	     error -> X;
	     {ok, D} ->
		 Dict2 = dict:store(VA, D - Amount, Dict),
		 X#d{dict = Dict2}
	 end,
    {noreply, X2};
handle_cast(sync, X) ->
    X2 = sync_internal(X),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, VA}, _From, X) -> 
    Dict = X#d.dict,
    Amount = 
	case dict:find(VA, Dict) of
	    {ok, Y} -> Y;
	    error -> 0
	end,
    {reply, Amount, X};
handle_call(_, _From, X) -> {reply, X, X}.

reduce(Amount, VA) -> gen_server:cast(?MODULE, {reduce, Amount, VA}).
read(VA) -> gen_server:call(?MODULE, {read, VA}).
sync() -> gen_server:cast(?MODULE, sync).


%% internal functions
sync_internal(X) ->
    MyHeight = X#d.height,
    NodeHeight = config:height(veo),
    if
	MyHeight >= NodeHeight -> X;
	true ->
	    Txs = tl(config:block_txs(MyHeight + 1)),%ignore coinbase tx.
	    VMe = config:pubkey(),
	    Dict2 = sync_block(X#d.dict, VMe, Txs),
	    X2 = X#d{dict = Dict2, height = MyHeight + 1},
	    sync_internal(X2)
    end.
sync_block(Dict, _, []) -> Dict;
sync_block(Dict, VMe, [H|T]) ->
    Tx = element(2, H),%remove signature.
    Dict2 = case element(1, Tx) of
	     spend ->
		 VT = config:spend_to(veo, Tx),
		 if
		     VT == VMe -> %spends to the server.
			 VA = config:spend_from(veo, Tx),
			 D = 
			     case dict:find(VA, Dict) of
				 {ok, Y} -> Y;
				 error -> 0
			     end,
			 B = config:spend_amount(veo, Tx),
			 NewAmount = D + B,
			 dict:store(VA, NewAmount, Dict);
		     true -> Dict
		 end;
	     _ -> Dict
	 end,
    sync_block(Dict2, VMe, T).
    


test() ->
    sync(),
    timer:sleep(300),
    VA = base64:decode(<<"BGRv3asifl1g/nACvsJoJiB1UiKU7Ll8O1jN/VD2l/rV95aRPrMm1cfV1917dxXVERzaaBGYtsGB5ET+4aYz7ws=">>),
    A = read(VA),
    D = 100,
    reduce(D, VA),
    B = read(VA),
    D = A-B,
    10000000 = A,
    success.
