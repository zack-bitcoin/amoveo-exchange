* loading veo into the order book.
* loading bitcoin into the order book.
* matching trades in the order book.


* keep a record of these things on the hard drive:
- id_lookup
- unconfirmed_veo
- unconfirmed_bitcoin
- order_book
- history_veo
- history_bitcoin

unconfirmed bitcoin needs to be written. mimic unconfirmed_veo.

veo_history probably shouldn't store the database as a giant list. Since this means that confirming each trade involves scanning the entire list, and making a copy in ram for unconfirmed_veo:confirm(), then that list gets scanned entirely in sum_amount.
* maybe we should be confirming multiple TID, so we only scan the list once for a batch.
* If we don't need to store the txs in one giant list, then we should consider doing a list of lists. each element in the top list is a list of all the txs from that block height.
- this helps because 100 dictionary lookups in a dictionary of size 200 is considerably faster than looking at every element of a list of 60,000 elements.


* maybe we should have a way to look up a Trade ID using some other information, like the bitcoin or veo address.

* a function should use unconfirmed_veo:confirm. We should periodically scan all the unconfirmed txs to see if any can be confirmed.


JS

* make a trade

* look up a trade by ID.
