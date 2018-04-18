%this gen server should lazily remember how much money they have sent us, and the last height we checked how much they sent us. 

%this attempts to mimic balance_veo.erl as much as possible.
-module(balance_bitcoin).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, sync/0, reduce/2, test/0]).
init(ok) -> 
    D = #d{height = max(0, config:height(bitcoin) - config:scan_history()), 
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
sync_internal(X) -> ok.


test() ->
    ok.
