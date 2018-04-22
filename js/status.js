(function(){
    var div = document.createElement("div");
    document.body.appendChild(div);
    var tid = input_text_maker("trade id: ");
    var button = button_maker("check trade status", button_function);
    div.append(button);
    function button_function() {
	var cmd = ["exist", tid.status];
	variable_public_get(cmd, function(x){
	    //we need to display the details of the trade.
	    return 0;});
    };
})();
