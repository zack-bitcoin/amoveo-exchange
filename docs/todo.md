======= Erlang

A gen_server to keep track of how much veo is controlled by each account.
* veo balance
* veo locked in trades

* sending veo to the server puts that veo into an account controlled by your private key.
- cron process keeps checking for the history of the full nodes address.

A JS page to display your veo balance on the server.
A JS page to withdrawal your veo from the exchange.

A gen_server keeping track of trades
* address giving veo
* address that will receive bitcoin
* address that will receive veo
* start block height
* expiration block height

A JS page for looking up trades

a gen_server for keeping record of a bitcoin address's balance, to see if it received the payment yet.


======= Future plans that we don't need for version 1.


======= Legal plan

only touch VEO.

Block IP’s from New York, Washington, Iran, or North Korea.  Reference restricted jurisdictions in terms of service.

Don’t host any servers in the US.

Europe – GDPR (data protection regulations) come into effect May 25th. Still unclear how exchanges should respond.  ShapeShift hasn’t released their policy re: GDPR but promises an update for the community soon – can probably piggyback on their strategy.

Terms of Service – Need to have terms of service.  Can copy and edit ShapeShift’s TOS, but there has to be some operator that is entering into the TOS with the users (probably don’t want this to be zack directly, could be a swiss or maltese corporation with zack as an owner, or whoever else as owner and just pays zack to consult.  Doesn’t really matter which from a legal standpoint).