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

* history_veo and history_bitcoin should ignore any incoming txs below some threshold. Don't waste ram.

* history_veo only needs to store when we receive money, not when we send it.


* maybe we should have a way to look up a Trade ID using some other information, like the bitcoin or veo address.


JS

* make a trade

* look up a trade by ID.
