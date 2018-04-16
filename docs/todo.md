======= Erlang

* We should periodically scan all the unconfirmed trades to see if any can be confirmed. use unconfirmed_veo_feeder:confirm_all().
* loading veo into order book needs to be tested.

Write bitcoin stuff to mimic veo stuff:
* write balance_bitcoin
* write unconfirmed_bitcoin
* write unconfirmed_bitcoin_feeder
* write hitory_bitcoin
* loading bitcoin into the order book.


* matching trades in the order book.
- cron job to periodically match trades in the order book.

* keep a backup of all gen_server data to the hard drive



======= JS

use the 2 api commands:
* make a trade
* look up a trade's status by ID.




====== Maybe

veo_history probably shouldn't store the database as a giant list. Since this means that confirming each trade involves scanning the entire list, and making a copy in ram for unconfirmed_veo:confirm(), then that list gets scanned entirely in sum_amount.
* maybe we should be confirming multiple TID, so we only scan the list once for a batch.
* If we don't need to store the txs in one giant list, then we should consider doing a list of lists. each element in the top list is a list of all the txs from that block height.
- this helps because 100 dictionary lookups in a dictionary of size 200 is considerably faster than looking at every element of a list of 60,000 elements.

* maybe we should have a way to look up a Trade ID using some other information, like the bitcoin or veo address.

