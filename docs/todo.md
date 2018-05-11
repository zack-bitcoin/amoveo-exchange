======= Erlang


* keep a record every time veo_balance or bitcoin_balance have income. Keep a record every time we pay a customer. These records can be used to know who owns which money if something goes wrong.

run tests for unconfirmed_bitcoin and balance_bitcoin

test to make sure utils:spend/3 is working.
test that order_book pays out the purchased currency.
test to make sure that profit_veo and profit_bitcoin are correctly sending the profit to cold storage.

* run lots of checks on input to api to make sure it is impossible to crash the order_book.erl gen_server. which could cause loss of customer funds.

* detailed instructions on how to use this tools for trading.

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


* What if there are unconfirmed payments at the same time a trade goes stale? We should probably let the trade exist longer until there are no unconfirmed payments, then pay the refund.

* consider the case where someone pays us more veo/bitcoin than the trade had said. We should give them a refund of the excess money they sent to us.