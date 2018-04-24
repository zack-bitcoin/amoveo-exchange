======= Erlang

* we need to figure out how adding timers to each trade will work. If the trade isn't fully matched after enough time, then we take it out of the market and give a refund to whoever sent it.

run tests for unconfirmed_bitcoin and balance_bitcoin

* keep a backup of all gen_server data to the hard drive
- don't back up so many excess times. only when we need to.

* it should occasionally move the profit to cold storage. We need to keep a record of how much of the money in the full node is needed to cover trades, and how much we can move to cold storage.

======= JS

use the api commands:
* make a trade
* look up a trade's status by ID.
* display a chart of open trades in the market

maybe use the open orders api to draw graphs.
