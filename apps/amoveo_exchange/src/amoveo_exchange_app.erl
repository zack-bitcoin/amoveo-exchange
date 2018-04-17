-module(amoveo_exchange_app).
-behaviour(application).
-export([start/2, stop/1]).
start(_StartType, _StartArgs) ->
    inets:start(),
    start_http(),
    start_balance_veo_sync(),
    confirm_veo_cron(),
    spawn(fun() ->
                  timer:sleep(1000),
                  %batches:start_cron(),
		  ok
          end),
    amoveo_exchange_sup:start_link().
stop(_State) ->
    ok.
start_http() ->
    Dispatch =
        cowboy_router:compile(
          [{'_', [{"/:file", file_handler, []},
		  {"/", http_handler, []}
		 ]}]),
    {ok, Port} = application:get_env(amoveo_exchange, port),
    {ok, _} = cowboy:start_http(
                http, 100,
                [{ip, {0, 0, 0, 0}}, {port, Port}],
                [{env, [{dispatch, Dispatch}]}]),
    ok.
confirm_veo_cron() ->
    spawn(fun() -> cvc() end).
cvc() ->
    timer:sleep(config:confirm_tx_period(veo)),
    spawn(fun() -> unconfirmed_veo_feeder:confirm_all() end),
    cvc().
		  
    
		  
start_balance_veo_sync() ->
    spawn(fun() -> sbvs() end).
sbvs() ->
    timer:sleep(config:sync_block_period(veo)),
    spawn(fun() -> balance_veo:sync() end),
    sbvs().
		  
		  
		  
