-module(bitcoin_height).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/0, update_cron/0]).
init(ok) -> {ok, config:height(bitcoin)}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(update, X) -> 
    H = config:height(bitcoin),
    X2 = max(H, X),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call(read, _From, X) -> 
    {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

read() -> gen_server:call(?MODULE, read).

update() -> gen_server:cast(?MODULE, update).
update_cron() -> %T is the delay in seconds
    spawn(fun() ->
		  update_cron2()
	  end).
update_cron2() ->
    T = config:bitcoin_height_check_delay(),
    timer:sleep(T*1000),
    spawn(fun() ->
		  update()
	  end),
    update_cron2().
