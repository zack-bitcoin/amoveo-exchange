-module(accounts).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	cron/0]).
-record(d, {height, accounts}).
-define(LOC, "accounts.db").
init(ok) -> 
    process_flag(trap_exit, true),
    H = utils:height(veo),
    R = #d{accounts = dict:new(), height = H},
    utils:init(R, ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(?LOC, X),
    io:format("accounts died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(update, X) -> 
    H = X#d.height,
    %check if we got paid in any new blocks.
    {noreply, X};
handle_cast(_, X) -> {noreply, X}.
handle_call(_, _From, X) -> {reply, X, X}.

update() -> gen_server:cast(?MODULE, update).

cron() ->
    spawn(fun() ->
		  timer:sleep(1000),
		  cron2()
	  end).
cron2() ->
    timer:sleep(5000),
    update(),
    cron2().
		  
