-module(account_history_veo).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/2, remove/2]).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({remove, TID, VA}, X) -> 
    X2 = case dict:find(VA, X) of
	     error -> X;
	     {ok, _} -> dict:erase(VA, X)
	 end,
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, TID, VA}, _From, X) -> 
    {CurrentHeight, CurrentAmount} = 
	case dict:find(VA, X) of
	    {ok, Y} -> Y;
	    error ->
		{config:height(veo) - 100, 0}
	end,
    CH = config:height(veo),
    ListTxs = history_veo:history(CurrentHeight, CH),%looks up the history of recent txs involving config:pubkey().
    %history_veo is a gen_server, because it is saving to ram recent trade data, so we don't keep downloading it from the amoveo full node.
    B = sum_amounts(VA, ListTxs),
    Store = {CH, CurrentAmount + B},
    X2 = dict:store(VA, Store, X),
    {reply, B, X2};
handle_call(_, _From, X) -> {reply, X, X}.

remove(TID, VA) ->
    gen_server:cast(?MODULE, {remove, TID, VA}).
read(TID, VA) ->
    gen_server:call(?MODULE, {read, TID, VA}).


%% internal functions
sum_amounts(_, []) -> 0;
sum_amounts(VA, [Tx|T]) ->
    VB = config:spend_from(veo, Tx),
    VTA = if
	      (VA == VB) ->
		  config:veo_tx_amount(Tx);
	      true -> 0
	  end,
    VTA + sum_amounts(VA, T).
