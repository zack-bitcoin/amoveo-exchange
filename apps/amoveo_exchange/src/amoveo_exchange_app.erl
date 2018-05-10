-module(amoveo_exchange_app).
-behaviour(application).
-export([start/2, stop/1]).
start(_StartType, _StartArgs) ->
    inets:start(),
    start_http(),
    veo_sync(),
    unconfirmed_veo_feeder:confirm_veo_cron(),
    unconfirmed_veo_feeder:stale_trades_cron(),
    unconfirmed_bitcoin_feeder:stale_trades_cron(),
    bitcoin_height:update_cron(),
    confirm_bitcoin_cron(),
    profit_bitcoin:cron(),
    profit_veo:cron(),
    order_book:batch_cron(),
    order_book:stale_cron(),
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
confirm_bitcoin_cron() ->
    spawn(fun() -> cbc() end).
cbc() ->
    timer:sleep(config:confirm_tx_period(bitcoin)),
    spawn(fun() -> unconfirmed_bitcoin_feeder:confirm_all() end),
    cbc().
		  
veo_sync() ->
    spawn(fun() -> veo_sync2() end).
veo_sync2() ->
    timer:sleep(config:sync_block_period(veo)),
    spawn(fun() -> balance_veo:sync() end),
    veo_sync2().
		  
		  
		  
