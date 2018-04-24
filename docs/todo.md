======= Erlang

* we need to figure out how adding timers to each trade will work. If the trade isn't fully matched after enough time, then we take it out of the market and give a refund to whoever sent it.
- There should probably be a 12 or 24 hour upper limit on how long trades can sit in the market before they are refunded.

run tests for unconfirmed_bitcoin and balance_bitcoin

* keep a backup of all gen_server data to the hard drive
- don't back up so many excess times. only when we need to.
- a shell script to delete all this saved data.

* it should occasionally move the profit to cold storage. We need to keep a record of how much of the money in the full node is needed to cover trades, and how much we can move to cold storage.

* in order_book.erl we should write the code for paying the veo and bitcoin for matched trades. (make sure each payment happens in a spawned function. If the gen_server crashes mid-way through making these payments, we could lose all the customer funds.)

* move a bunch of functions in config.erl to other modules. There are notes in config.erl.

* make a cold bitcoin and cold veo address for the config.erl file

======= JS

use the api commands:
* make a trade
* look up a trade's status by ID.
* display a chart of open trades in the market. maybe a graph too.
