(function(){
    var div = document.createElement("div");
    document.body.appendChild(div);
    var trade_type = input_text_maker("write 'sell' if you are selling veo, write 'buy' if you are buying veo", div):
    var veo_amount = input_text_maker("amount of veo: ", div);
    var bitcoin_amount = input_text_maker("amount of bitcoin: ", div);
    var time_limit = input_text_maker("time_limit (default: 1 hour): ", div);
    time_limit.value = "60";
    var customer_veo_address = input_text_maker("customer's veo address. if selling veo, spend the veo from here. if buying veo, you will be paid here. You might get a refund to this address.", div);
    var customer_bitcoin_address = input_text_maker("customer's bitcoin address. If you are buying veo, you might get a refund to this address. If you are selling veo, this is where you will get paid.", div);

    var button = button_maker("make trade", button_function, div);
    div.append(button);
    function button_function() {
	var tt = 1;
	var va = parseInt(veo_amount.value);
	var ba = parseInt(bitcoin_amount.value);
	var tl = parseInt(time_limit.value);
	if ((trade_type.value == "sell") || (trade_type.value = "'sell'")) { tt = 2; };
	var cmd = ["bet", tt, customer_veo_address.value, customer_bitcoin_address.value, va, ba, tl];
	variable_public_get(cmd, function(X){
	    console.log(X);
	    //we need to display the trade id so they can look it up.
	    return 0;});
    };
})();
