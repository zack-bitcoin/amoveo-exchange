-module(profit_bitcoin).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	gain/1, store/0, check/0, cron/0]).
-define(LOC, config:file(?MODULE)).
init(ok) -> 
    process_flag(trap_exit, true),
    utils:init(0, ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(X, ?LOC),
    io:format("profit bitcoin died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({gain, N}, X) -> 
    {noreply, X+N};
handle_cast(store, X) -> 
    utils:spend(bitcoin, config:cold(bitcoin), X),
    {noreply, 0};
handle_cast(_, X) -> {noreply, X}.
handle_call(check, _From, X) -> 
    {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

gain(N) when (is_integer(N) and (N > -1)) ->
    gen_server:cast(?MODULE, {gain, N}).
store() ->
    N = check(),
    PL = config:profit_limit(bitcoin),
    if 
	N > PL ->
	    gen_server:cast(?MODULE, store);
	true -> ok
    end.
check() -> gen_server:call(?MODULE, check).
cron() ->
    spawn(fun() -> cron2() end).
cron2() ->
    timer:sleep(config:profit_check_period(bitcoin)),
    spawn(fun() -> store() end),
    cron2().
    
    
		  
