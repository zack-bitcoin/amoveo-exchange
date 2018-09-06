var pubkey = document.createElement("INPUT");
lookup_account1();
function lookup_account1() {
    var title = document.createElement("h3");
    title.innerText = "View Balance in Escrow for Address";
    document.getElementById('account').appendChild(title);
    var lookup_account = document.createElement("div");
    document.getElementById('account').appendChild(lookup_account);
    pubkey.setAttribute("type", "text");
    var input_info = document.createElement("h8");
    input_info.innerHTML = "Enter the public key: ";
    document.getElementById('account').appendChild(input_info);
    document.getElementById('account').appendChild(pubkey);

    var lookup_account_button = document.createElement("BUTTON");
    var lookup_account_text_node = document.createTextNode("lookup account");
    lookup_account_button.appendChild(lookup_account_text_node);
    lookup_account_button.onclick = lookup_account_helper;
    document.getElementById('account').appendChild(lookup_account_button);
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
	    var s = "balance = ".concat(bal.toString()).concat(", locked veo = ".concat(locked.toString()).concat(", trade ids ").concat(JSON.stringify(decode_trades(trades))));
	    lookup_account.innerHTML = s;
	}
	//veo, locked veo, request ids
    }
    function decode_trades(l) {
	var r = [];
	for (i=0;i<l.length;i++) {
	    r.push(atob(l[i]))
	}
	return r;
    }

}
