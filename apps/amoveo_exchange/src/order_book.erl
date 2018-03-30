-module(order_book).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 next_batch_time/0
	]).
-record(d, {buy_veo = [], sell_veo = [], last_match_time}).
-record(order, {give, take, time_limit}).
-define(File, "order_book.db").
initial_state() ->
    #d{last_match_time = erlang:timestamp()}.
init(ok) ->
    A = case file:read_file(?File) of
	    {error, enoent} -> initial_state();
	    {ok, B} ->
		case B of
		    "" -> initial_state();
		    _ -> binary_to_term(B)
		end
	end,
    {ok, A}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(_, X) -> {noreply, X}.
handle_call(_, _From, X) -> {reply, X, X}.


next_batch_time() -> ok.
