%this gen server should lazily remember how much money they have sent us, and the last height we checked how much they sent us. 

%this attempts to mimic balance_veo.erl as much as possible.
-module(balance_bitcoin).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, reduce/2, test/0]).
-include("records.hrl").
-define(LOC, config:file(?MODULE)).
-record(acc, {received = 0, spent = 0, height = 0}).%received is the total amount of bitcoin sent to this account for the height
%spent is how many of these have either been spent in trades, or been refunded to the customer.
init(ok) -> 
    process_flag(trap_exit, true),
    utils:init(dict:new(), ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(X, ?LOC),
    io:format("balance bitcoin died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({reduce, Amount, VA}, Dict) -> 
    X2 = case dict:find(VA, Dict) of
	     error -> Dict;
	     {ok, D} ->
		 D2 = D#acc{spent = Amount + D#acc.spent},
		 Dict2 = dict:store(VA, D2, Dict),
		 Dict#d{dict = Dict2}
	 end,
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, VA, Height}, _From, Dict) -> 
    {Y3, Dict2} = 
	case dict:find(VA, Dict) of
	    {ok, Y} -> 
		H2 = Y#acc.height,
		if
		    H2 < Height ->
			B = utils:address_received(bitcoin, VA, config:confirmations()),
			Y2 = Y#acc{height = Height, received = B},
			{Y2, dict:store(VA, Y2, Dict)};
		    true -> {Y, Dict}
		end;
	    error -> {#acc{}, Dict}
	end,
    A = Y3#acc.received - Y3#acc.spent,
    {reply, A, Dict2};
handle_call(_, _From, X) -> {reply, X, X}.

reduce(Amount, VA) -> gen_server:cast(?MODULE, {reduce, Amount, VA}).
read(VA) -> 
    H = bitcoin_height:read(),
    gen_server:call(?MODULE, {read, VA, H}).

test() ->
    ok.
