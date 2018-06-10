var pubkey = document.createElement("INPUT");
lookup_account1();
function lookup_account1() {
    document.body.appendChild(document.createElement("br"));
    document.body.appendChild(document.createElement("br"));
    var lookup_account = document.createElement("div");
    document.body.appendChild(lookup_account);
    pubkey.setAttribute("type", "text");
    var input_info = document.createElement("h8");
    input_info.innerHTML = "pubkey: ";
    document.body.appendChild(input_info);
    document.body.appendChild(pubkey);

    var lookup_account_button = document.createElement("BUTTON");
    var lookup_account_text_node = document.createTextNode("lookup account");
    lookup_account_button.appendChild(lookup_account_text_node);
    lookup_account_button.onclick = lookup_account_helper;
    document.body.appendChild(lookup_account_button);
    function lookup_account_helper() {
        var x = pubkey.value;
        variable_public_get(["account", x], lookup_account_helper2);
    }
    function lookup_account_helper2(x) {
	if (x == 0) {
	    lookup_account.innerHTML = "no account";
	} else {
	    console.log(x);
	    var bal = x[1];
	    var locked = x[2];
	    var trades = x[3];
	    var bal = x[1];
	    var locked = x[2];
	    var trades = x[3].slice(1);
	    var s = "balance = ".concat(bal.toString()).concat(", locked veo = ".concat(locked.toString()).concat(", trade ids ").concat(JSON.stringify(trades)));
	    lookup_account.innerHTML = s;
	}
	//veo, locked veo, request ids
    }

}
