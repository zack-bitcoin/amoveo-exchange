======= Erlang

* making secure backed-up addresses for bitcoin.

* config:height(bitcoin). needs to be implemented

Write bitcoin stuff to mimic veo stuff:
* write balance_bitcoin
-sync_internal/1
-test/0
* write unconfirmed_bitcoin
* write unconfirmed_bitcoin_feeder
* loading bitcoin into the order book.


* matching trades in the order book.
- cron job to periodically match trades in the order book.

* keep a backup of all gen_server data to the hard drive

======= JS

use the 2 api commands:
* make a trade
* look up a trade's status by ID.

use the open orders api to draw graphs.

====== API

* look up open orders in the order book.