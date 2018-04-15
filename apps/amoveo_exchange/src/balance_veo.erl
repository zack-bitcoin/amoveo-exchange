%this gen server should lazily remember how much money they have sent us, and the last height we checked how much they sent us. If the last height we checked is lower than the current height, then use history_veo to look up the recent txs, and update the amount they have sent us.

-module(balance_veo).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 read/1, 
	 remove/2,%reduces how many veo are controlled by this account.
	 test/0]).
init(ok) -> {ok, dict:new()}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({remove, Amount, VA}, X) -> 
    X2 = case dict:find(VA, X) of
	     error -> X;
	     {ok, {CH, A}} ->
		 A2 = A - Amount,
		 dict:store(VA, {CH, A2}, X)
	 end,
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, VA}, _From, X) -> 
    {CurrentHeight, CurrentAmount} = 
	case dict:find(VA, X) of
	    {ok, Y} -> Y;
	    error ->
		{max(0, config:height(veo) - 100), 0}
	end,
    CH = config:height(veo),
    ListTxs = history_veo:history(CurrentHeight, CH),%looks up the history of recent txs involving config:pubkey().
    %history_veo is a gen_server, because it is saving to ram recent trade data, so we don't keep downloading it from the amoveo full node.
    B = sum_amounts(VA, ListTxs),
    NewAmount = CurrentAmount + B,
    Store = {CH, NewAmount},
    X2 = dict:store(VA, Store, X),
    {reply, NewAmount, X2};
handle_call(_, _From, X) -> {reply, X, X}.

remove(Amount, VA) ->
    gen_server:cast(?MODULE, {remove, Amount, VA}).
read(VA) ->
    gen_server:call(?MODULE, {read, VA}).


%% internal functions
sum_amounts(_, []) -> 0;
sum_amounts(VA, [STx|T]) ->
    Tx = element(2, STx),
    VB = config:spend_from(veo, Tx),
    %VB is a spend tx. this is wrong.
    VTA = if
	      (VA == VB) ->
		  config:spend_amount(veo, Tx);
	      true -> 0
	  end,
    VTA + sum_amounts(VA, T).

test() ->
    VA = base64:decode(<<"BGRv3asifl1g/nACvsJoJiB1UiKU7Ll8O1jN/VD2l/rV95aRPrMm1cfV1917dxXVERzaaBGYtsGB5ET+4aYz7ws=">>),
    A = read(VA),
    A = read(VA),
    D = 100,
    remove(D, VA),
    B = read(VA),
    D = A-B.
