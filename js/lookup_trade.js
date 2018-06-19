(function lookup_trade() {
    document.body.appendChild(document.createElement("br"));
    var div = document.createElement("div");
    document.getElementById('buyer').appendChild(div);
    var button = document.createElement("input");
    button.type = "button";
    button.value = "lookup trade";
    button.onclick = lookup;
    div.appendChild(button);
    var bitcoin_address = input_text_maker("bitcoin address of trade being looked up", div);
    var trade_div = document.createElement("div");
    div.appendChild(trade_div);
    
    function lookup() {
	variable_public_get(["exist", btoa(bitcoin_address.value)], function(trade) {
	    //trade_div.innerHTML = JSON.stringify(trade);
	    //["trade", "BAiwm5uz5bLkT+Lr++uNI02jU3Xshwyzkywk0x0ARwY5j4lwtxbKpU+oDK/pTQ1PLz7wyaEeDZCyjcwt9Foi2Ng=", 8, "MUdNcDFzOVdmWFBCN1lZTDh4YlVWRlM0Y1lVV045djFKWA==", "BCjdlkTKyFh7BBx4grLUGFJCedmzo4e0XT1KJtbSwq5vCJHrPltHATB+maZ+Pncjnfvt9CsCcI9Rn1vO+fPLIV4=", Array(4), 600, 1, 1, 1000000]
	    console.log(trade);
	    var sv = trade[1];
	    var rb = atob(trade[3]);
	    var rv = trade[4];
	    var start_time = trade[5];
	    var time_limit = trade[6];
	    var veo_amount = trade[7];
	    var bitcoin_amount = trade[8];
	    console.log("start time");
	    console.log(start_time);
	    var t1 = start_time[1];
	    var t2 = start_time[2];
	    var t3 = (t1 * 1000000) + t2;
	    var tn = Date.now();
	    var seconds_since_start = Math.floor((tn - (t3 * 1000)) / 1000);
	    var time_left = time_limit - seconds_since_start;

	    
	    var s = "selling veo: ".concat(sv).concat(", buying veo: ").concat(rv).concat(", receiving bitcoin: ").concat(rb).concat(", time left (in seconds): ").concat(parseInt(time_left)).concat(", veo amount: ").concat((veo_amount/100000000).toString()).concat(", bitcoin amount: ").concat((bitcoin_amount/100000000).toString());
	    trade_div.innerHTML = JSON.stringify(s);
	    console.log(trade);
	});
    }
    
})();
