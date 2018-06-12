(function trade() {
    document.body.appendChild(document.createElement("br"));
    var div = document.createElement("div");
    document.body.appendChild(div);

    var button = document.createElement("input");
    button.type = "button";
    button.value = "generate unsigned trade request";
    button.onclick = generate_unsigned_request;
    var unsigned_div = document.createElement("div");

    //inputs for all the info in a trade
    //bitcoin_address, veo_to, time_limit, veo_amount, bitcoin_amount
    var bitcoin_address = input_text_maker("bitcoin address that will receive bitcoins", div);
    div.appendChild(document.createElement("br"));
    var veo_to = input_text_maker("address that will receive VEO", div);
    div.appendChild(document.createElement("br"));
    var time_limit = input_text_maker("time limit in seconds. If the bitcoin doesn't arrive within this limit, then the veo is refunded", div);
    div.appendChild(document.createElement("br"));
    time_limit.value = "18000";
    var veo_amount = input_text_maker("how many veo to sell", div);
    div.appendChild(document.createElement("br"));
    var bitcoin_amount = input_text_maker("how many bitcoin to buy", div);
    div.appendChild(document.createElement("br"));
    
    var button2 = document.createElement("input");
    button2.type = "button";
    button2.value = "publish signed trade request";
    button2.onclick = publish_signed_request;
    var signed = document.createElement("input");
    signed.type = "text";
    
    div.appendChild(button);
    div.appendChild(unsigned_div);
    div.appendChild(button2);
    div.appendChild(signed);


    var instructions = document.createElement("div");
    instructions.innerHTML = "To sign, you can use a light node, like the one linked from this page: https://github.com/zack-bitcoin/amoveo";
    div.appendChild(instructions);

    function generate_unsigned_request(){
	variable_public_get(["height"], function(height) {
	    variable_public_get(["pubkey"], function(server_pubkey) {
		var ba2 = Math.floor(parseFloat(bitcoin_amount.value) * 100000000);
		var va2 = Math.floor(parseFloat(veo_amount.value) * 100000000);
		var request = [-7, 29, pubkey.value, height, btoa(bitcoin_address.value), veo_to.value, parseInt(time_limit.value), parseInt(veo_amount.value), ba2, server_pubkey];
		unsigned_div.innerHTML = JSON.stringify(request);
	    });
	});
    };
    function publish_signed_request(){
	var sr = JSON.parse(signed.value);
	variable_public_get(["trade", sr], function(x) {
	    console.log("publish signed request");
	});

    }

})();
