-record(trade, {type, veo_address, bitcoin_address, veo_amount, bitcoin_amount, time_limit = 0, time = 0, id = 0}). %if selling veo, then bitcoin_address is the customer's address. If buying veo, then bitcoin_address is one of the server's addresses.

-record(d, {height, dict}).