(function server_pub() {
    document.body.appendChild(document.createElement("br"));
    var div = document.createElement("div");
    document.body.appendChild(div);
    console.log("request");
    variable_public_get(["pubkey"], function(pub) {
	console.log("returned");
	div.innerHTML = ("deposit address: ").concat(atob(pub));
    });
})();
