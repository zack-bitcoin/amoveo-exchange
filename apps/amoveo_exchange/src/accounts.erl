-module(accounts).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	cron/0,get/1,withdrawal/1,lock/3]).
-record(d, {height, accounts}).
-record(acc, {veo = 0, locked = 0, rids = [], nonce = 0}).
empty_account() -> #acc{}.
    
-define(LOC, "accounts.db").
init(ok) -> 
    process_flag(trap_exit, true),
    H = case config:mode() of
	    test -> 0;
	    production -> utils:height(veo)
	end,
    R = #d{accounts = dict:new(), height = H},
    utils:init(R, ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(?LOC, X),
    io:format("accounts died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({withdrawal, Pubkey}, X) -> 
    A = X#d.accounts,
    X2 = case dict:find(Pubkey, A) of
	     error -> X;
	     {ok, Acc} ->
		 Amount = Acc#acc.veo,
		 utils:spend(veo, Pubkey, Amount),
		 Acc2 = Acc#acc{veo = 0},
		 A2 = dict:write(Pubkey, Acc2, A),
		 X#d{accounts = A2}
	 end,
    {noreply, X2};
handle_cast(update, X) -> 
    H = X#d.height,
    NewHeight = utils:height(veo),
    Pubkey = utils:pubkey(),
    X2 = if
	NewHeight > H ->
		 M = {pubkey, Pubkey, NewHeight - H, NewHeight},%amoveo_utils:address_history
		 {ok, Txs} = talker:talk(M),
		 io:fwrite("txs "),
		 io:fwrite(packer:pack(Txs)),
		 io:fwrite("\n"),
		 A2 = receive_payments(Txs, X#d.accounts, Pubkey),
		 X#d{height = NewHeight, accounts = A2};
	true -> X
    end,
    {noreply, X2};
handle_cast({unlock, Pubkey, Amount}, X) ->
    Accs = X#d.accounts,
    Account4 = dict:fetch(Pubkey, Accs),
    Account5 = Account4#acc{locked = Account4#acc.locked - Amount, veo = Account4#acc.veo + Amount},
    Accs2 = dict:write(Pubkey, Account5, Accs),
    X2 = X#d{accounts = Accs2},
    {noreply, X2};
handle_cast({transfer_locked, From, To, Amount}, X) -> 
    Accs = X#d.accounts,
    Account2 = case dict:find(To, Accounts) of
		   error -> #acc{};
		   {ok, A} -> A
	       end,
    Account3 = Account2#acc{veo = Account2#acc.veo + Amount},
    Account4 = dict:fetch(From, Accs),
    Account5 = Account4#acc{locked = Account4#acc.locked - Amount},
    Accs2 = dict:write(To, Account3, Accs),
    Accs3 = dict:write(From, Account5, Accs2),
    X2 = X#d{accounts = Accs3},
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({lock, Pub, Amount, StartHeight}, _, X) ->
    Accs = X#d.accounts,
    {ok, A} = dict:find(Pub, Accs),
    {Q, X2} = 
	case dict:find(Pub, Accs) of
	    error -> {<<"account does not exist">>, X};
	    {ok, A} ->
		if 
		    StartHeight =< A#acc.nonce ->
			{<<"no request reuse">>, X};
		    Amount > A#acc.veo -> {<<"you don't have enough veo to do that">>, X};
		    true ->
			A2 = A#acc{nonce = StartHeight,
				   veo = A#acc.veo - Amount},
			Acc2 = dict:write(Pub, A2, Accs),
			X3 = X#d{accounts = Acc2},
			{success, X3}
		end
	end,
    {reply, Q, X2};

handle_call({get, Pub}, _From, X) -> 
    Accs = X#d.accounts,
    Y = dict:find(Pub, Accs),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

withdrawal(Pub) -> gen_server:cast(?MODULE, {withdrawal, Pub}).
lock(Pub, Amount, StartHeight) -> gen_server:cast(?MODULE, {lock, Pub, Amount, StartHeight}).
update() -> gen_server:cast(?MODULE, update).
get(Pub) -> gen_server:call(?MODULE, {get, Pub}).
transfer_locked(From, To, Amount) ->
    gen_server:cast(?MODULE, {transfer_locked, From, To, Amount}).
unlock(Pubkey, Amount) ->
    gen_server:cast(?MODULE, {unlock, Pubkey, Amount}).
    
receive_payments([], X, _) -> X;
receive_payments([{_, Tx}|T], X, Pubkey) ->
   %Txs is [{Height, UnsignedTx}...]
   %add the veo to their balance, minus the deposit fee.
    DF = config:deposit_fee(),
    From = utils:spend_from(veo, Tx),
    Amount = utils:spend_amount(veo, Tx),
    X2 = if
	     Pubkey == From -> X;%only look at txs that receive veo.
	     Amount < DF -> X;
	     true ->
		 rp2(From, Amount - DF, X)
		     %dict:store(From, A2, X)
		     %X#d{accounts = A2
    end,
    receive_payments(T, X2, Pubkey).
rp2(From, A, D) ->
    Acc = case dict:find(From, D) of
	      error -> #acc{};
	      {ok, X} -> X
	  end,
    Acc2 = Acc#acc{veo = Acc#acc.veo + A},
    dict:store(From, Acc2, D).
	    




cron() ->
    spawn(fun() ->
		  timer:sleep(5000),
		  cron2()
	  end).
cron2() ->
    timer:sleep(5000),
    update(),
    cron2().
		  
