======= Erlang

* we need to figure out how adding timers to each trade will work. If the trade isn't fully matched after enough time, then we take it out of the market and give a refund to whoever sent it.

Write bitcoin stuff to mimic veo stuff:
-test/0

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