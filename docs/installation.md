1) install amoveo https://github.com/zack-bitcoin/amoveo

2) look in the config.erl file. Change cold_bitcoin to a bitcoin address that you control. Change cold_veo to a amoveo address that you control. This is where the profit from the exchange will go.
There are many other variables in this file which you might want to customize for your exchange.



WARNING
Make a new unused amoveo address for your exchange.
If you delete the files on your hard drive to restart the exchange with an empty order book, make sure to generate a new address for your amoveo node. make sure not to reuse an old address. Otherwise you could lose customer funds.
