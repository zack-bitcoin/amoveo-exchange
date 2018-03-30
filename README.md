amoveo_exchange
=====

This is an exchange written for trades between bitcoin and amoveo.

===  turn it on
```
sh start.sh
```

=== attach to exchange so you can issue commands
```
sh attach.sh
```
you can detach by holding the control key and pressing the D key.


The order book matches trades in batches.
It selects a price to match as many trades as possible.
It prefers the price where people who are buying Veo are getting the best deal possible.