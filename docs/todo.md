======= Erlang

* we need to figure out how adding timers to each trade will work. If the trade isn't fully matched after enough time, then we take it out of the market and give a refund to whoever sent it.
- There should probably be a 12 or 24 hour upper limit on how long trades can sit in the market before they are refunded.

run tests for unconfirmed_bitcoin and balance_bitcoin

a command to update the backups without shutting off.

* it should occasionally move the profit to cold storage. We need to keep a record of how much of the money in the full node is needed to cover trades, and how much we can move to cold storage.
- every time a trade is funded, add the fee to our profit gen_server.
- if the profit gets high enough, then spend some of it to cold storage.

* in order_book.erl we need the code for paying the veo and bitcoin for matched trades. (make sure each payment happens in a spawned function. If the gen_server crashes mid-way through making these payments, we could lose all the customer funds.)
- spend functions should be in utils, so we can reuse the same functions for moving profit to cold storage.

* make a cold bitcoin and cold veo address for the config.erl file

* make the message_limit in http_handler for market_data more strict. We don't want to send so much data too frequently.

* it would be nice if users could cancel their trades. Maybe they should send a signed message, or maybe they should send a payment of exactly 1 satoshi.
- maybe the light node should have a feature to sign messages?

======= JS

use the api commands:
* make a trade
* look up a trade's status by ID.
* display a chart of open trades in the market. maybe a graph too.
