-record(trade, {type, %changes with each step.
	        veo_address, %customer's address
	       	bitcoin_address, %customer's address
		veo_amount,
		bitcoin_amount,
		time_limit = 0,
		time = 0,
		id = 0,
		server_bitcoin_address = 0}).

-record(d, {height, dict}).