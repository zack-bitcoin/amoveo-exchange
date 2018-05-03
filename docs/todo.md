======= Erlang

* we need to figure out how adding timers to each trade will work. If the trade isn't fully matched after enough time, then we take it out of the market and give a refund to whoever sent it.
- There should probably be a 12 hour max we store the trade on the server until we give a refund. it is a config.erl variable.
- trades can also go stale in the unconfirmed step. If they are partially funded, we should send a refund.
 * What if there are unconfirmed payments at the same time a trade goes stale? We should probably let the trade exist longer until there are no unconfirmed payments, then pay the refund.

run tests for unconfirmed_bitcoin and balance_bitcoin

test to make sure utils:spend/3 is working.
test that order_book pays out the purchased currency.
test to make sure that profit_veo and profit_bitcoin are correctly sending the profit to cold storage.


======= JS

use the api commands:
* make a trade
* look up a trade's status by ID.
* display a chart of open trades in the market. maybe a graph too.



======= Future plans that we don't need for version 1.

* it would be nice if users could cancel their trades. Maybe they should send a signed message, or maybe they should send a payment of exactly 1 satoshi.
- maybe the light node should have a feature to sign messages?

* a command to update the backups without shutting off.

* look up what the current trading fees are
- api
- javascript