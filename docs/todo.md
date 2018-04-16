======= Erlang

in veo_history:
* we should delete the information as soon as we learned about it and stored it in account_history_veo, or learned that it was invalid.
O(number of transactions) is much better than O((number of transactions) * (number of traders))

* We should periodically scan all the unconfirmed trades to see if any can be confirmed. use unconfirmed_veo_feeder:confirm_all().
* loading veo into order book needs to be tested.

Write bitcoin stuff to mimic veo stuff:
* write history_bitcoin
* write balance_bitcoin
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

