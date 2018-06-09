-module(accounts).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	cron/0,get/1]).
-record(d, {height, accounts}).
-record(acc, {veo = 0, locked = 0, rids = []}).
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
    NewHeight = utils:height(veo),
    Pubkey = utils:pubkey(),
    if
	NewHeight > H ->
	    M = {pubkey, Pubkey, NewHeight - H, NewHeight},%amoveo_utils:address_history
	    {ok, Txs} = talker:talk(M),
	    A2 = receive_payments(Txs, X#d.accounts, Pubkey),
	    X2 = X#d{height = NewHeight, accounts = A2},
	    ok;
	true ->
	    {noreply, X}
    end;
handle_cast(_, X) -> {noreply, X}.
handle_call({get, Pub}, _From, X) -> 
    Accs = X#d.accounts,
    Y = dict:find(Pub, Accs),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

update() -> gen_server:cast(?MODULE, update).
get(Pub) -> gen_server:call(?MODULE, {get, Pub}).
    
receive_payments([], X, _) -> X;
receive_payments([{_, Tx}|T], X, Pubkey) ->
   %Txs is [{Height, UnsignedTx}...]
   %add the veo to their balance, minus the deposit fee.
    DF = config:deposit_fee(),
    From = utils:spend_from(Tx),
    Amount = utils:spend_amount(Tx),
    X2 = if
	Pubkey == From -> X;%only look at txs that receive veo.
	Amount < DF -> X;
	true ->
	    A2 = rp2(From, Amount - DF, X#d.accounts),
	    X#d{accounts = A2}
    end,
    receive_payments(T, X2, Pubkey).
rp2(From, A, D) ->
    Acc = case dict:find(From, D) of
	      error -> #acc{};
	      {ok, X} -> X
	  end,
    Acc#acc{veo = Acc#acc.veo + A}.
	    




cron() ->
    spawn(fun() ->
		  timer:sleep(1000),
		  cron2()
	  end).
cron2() ->
    timer:sleep(5000),
    update(),
    cron2().
		  

