(function(){
  // the step 5 container
  var div = document.createElement("div");
  div.setAttribute('class', 'seller__step5');

  // left side
  var inputDiv = document.createElement("div");
  inputDiv.setAttribute('class', 'seller__step5-input');
  var tradeReqIn = document.createElement("textarea");
  tradeReqIn.setAttribute('id', 'seller__step5-tradeReqIn');
  tradeReqIn.setAttribute("placeholder", "Copy your signed trade request here.")
  inputDiv.appendChild(tradeReqIn);
  var button2 = document.createElement("input");
  button2.type = "button";
  button2.value = "publish signed trade request";
  button2.onclick = publish_signed_request;
  button2.setAttribute('class', 'seller__step3-btn btn')
  inputDiv.appendChild(button2);
  div.appendChild(inputDiv);

  // right side 
  var toSendDiv = document.createElement("div");
  toSendDiv.setAttribute('class', 'seller__step5-to-send');
  var tradeReqOut = document.createElement("textarea")
  tradeReqOut.setAttribute('id', 'seller__step5-tradeReqOut');
  tradeReqOut.setAttribute("placeholder", "Your shareable trade request will appear here. You must copy the whole string then send it to your buyer.")
  toSendDiv.appendChild(tradeReqOut);
  div.appendChild(toSendDiv);

  // heading for step 5
  var heading = document.createElement("h3");
  heading.innerHTML = "5. Publish your signed trade request"

  // the container for sellers
  var sellerContainer = document.getElementsByClassName('seller')[0];
  sellerContainer.appendChild(heading);
  sellerContainer.appendChild(div);


  function publish_signed_request(){
    var sr = JSON.parse(tradeReqIn.value);
    variable_public_get(["trade", sr], function(x) {
      tradeReqOut.value = JSON.stringify(x);
    });
  }
})();