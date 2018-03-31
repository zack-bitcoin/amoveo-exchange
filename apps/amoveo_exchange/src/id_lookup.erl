%This gen server is for looking up the status of any trade.
%once you know the status, then you know which gen_server it is located in.

-module(id_lookup).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1, add_veo/1, add_bitcoin/1, confirm/1, finalize/1]).
init(ok) -> {ok, dict:new()}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({add_veo, ID}, X) -> 
    Y = dict:store(ID, 1, X),
    {noreply, Y};
handle_cast({add_bitcoin, ID}, X) -> 
    Y = dict:store(ID, 2, X),
    {noreply, Y};
handle_cast({confirm, ID}, X) -> 
    Y = dict:store(ID, 3, X),
    {noreply, Y};
handle_cast({finalize, ID}, X) -> 
    Y = dict:store(ID, 4, X),
    {noreply, Y};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, ID}, _From, X) -> 
    Y = dict:find(ID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(ID) -> 
    X = gen_server:call(?MODULE, {read, ID}),
    case X of
	error -> empty;
	1 -> unconfirmed_veo;
	2 -> unconfirmed_bitcoin;
	3 -> unmatched;
	4 -> history
    end.
	    

add_veo(ID) -> 
    empty = read(ID),
    gen_server:cast(?MODULE, {add_veo, ID}).
add_bitcoin(ID) -> 
    empty = read(ID),
    gen_server:cast(?MODULE, {add_bitcoin, ID}).
confirm(ID) -> 
    ok = case read(ID) of
	     1 -> ok;
	     2 -> ok
	 end,
    gen_server:cast(?MODULE, {confirm, ID}).
finalize(ID) -> 
    3 = read(ID),
    gen_server:cast(?MODULE, {finalize, ID}).
    
    
