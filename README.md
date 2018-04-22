amoveo_exchange
=====

This is a work in progress. It does not yet function as an exchange.


This is an exchange written for trades between bitcoin and amoveo.

[installation](docs/installation.md)
[turn it on](docs/boot_up.md)

The order book matches trades in single-price batches.
It selects a price to match as many trades as possible.

It is a shapeshift style exchange. There are no accounts or passwords.
You give the details of the trade you want to make, and we provide an address to send your coins to, and a Trade-ID so you can look up the status of your trade.
Each trade has a customizable time limit. If your trade doesn't get matched or only gets partially matched by the time limit, then we refund your remaining balance.

[what needs to get done](docs/todo.md)


====== Warnings

* this is in development. It is not yet functioning software. You cannot use it as an exchange yet.

* If you ever deleted the database for any reason, it is important to change your public key in the veo full node. Otherwise you could accept payments from your history that are no longer valid. Allowing people to trade in your market without paying you.
