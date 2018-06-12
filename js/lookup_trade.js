(function lookup_trade() {
    document.body.appendChild(document.createElement("br"));
    var div = document.createElement("div");
    var button = document.createElement("input");
    button.type = "button";
    button.value = "lookup trade";
    button.onclick = lookup;
    div.appendChild(button);
    var bitcoin_address = input_text_maker("bitcoin address of trade being looked up", div);
    var trade_div = document.createElement("div");
    div.appendChild(trade_div);
    
    function lookup() {
	variable_public_get(["exist", bitcoin_address.value], function(trade) {
	    trade_div.innerHTML = JSON.stringify(trade);
	    console.log(trade);
	});
    }
    
})();
