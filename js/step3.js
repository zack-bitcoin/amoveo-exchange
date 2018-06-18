(function(){
  // the step 3 container
  var div = document.createElement("div");
  div.setAttribute('class', 'seller__step3');

  // left side
  var inputDiv = document.createElement("div");
  inputDiv.setAttribute('class', 'seller__step3-input');
  div.appendChild(inputDiv);

  // heading for step 3
  var heading = document.createElement("h3");
  heading.innerHTML = "3. Generate an unsigned trade request"

  // the container for sellers
  var sellerContainer = document.getElementsByClassName('seller')[0];
  sellerContainer.appendChild(heading);
  sellerContainer.appendChild(div);

  // right side
  var toSendDiv = document.createElement("div");
  toSendDiv.setAttribute('class', 'seller__step3-to-send');
  var unsigned_div = document.createElement("textarea")
  unsigned_div.setAttribute('id', 'seller__step3-unsigned');
  unsigned_div.setAttribute("placeholder", "Your unsigned trade request will appear here. You must copy the whole string then sign it using a light wallet.")
  toSendDiv.appendChild(unsigned_div);
  toSendDiv.innerHTML += "<strong>Warning!</strong> Only participate in a trade if there is enough time for your bitcoin tx to get 3 confirmations. We suggest at least 90 minutes = 5400 seconds."
  div.appendChild(toSendDiv);

  //inputs for all the info in a trade
  //bitcoin_address, veo_to, time_limit, veo_amount, bitcoin_amount
  var btcInstructions = document.createElement("small");
  btcInstructions.innerHTML = "Enter the bitcoin address that will receive bitcoins";
  var bitcoin_address = input_text_maker(btcInstructions, inputDiv);
  var veoInstructions = document.createElement("small");
  veoInstructions.innerHTML = "Enter the Amoveo address that will receive VEO";
  var veo_to = input_text_maker(veoInstructions, inputDiv);
  var timeInstructions = document.createElement("small");
  timeInstructions.innerHTML = "Enter bitcoin transaction expiration in seconds. This is how long your counterparty has to transfer bitcoins before you get your VEO refunded";
  var time_limit = input_text_maker(timeInstructions, inputDiv);
  time_limit.setAttribute('value', "18000");
  var veoAmtInstructions = document.createElement("small");
  veoAmtInstructions.innerHTML = "VEO to sell. This should auto-populate once you fill in the form in Step 1";
  var veo_amount = input_text_maker(veoAmtInstructions, inputDiv);
  veo_amount.setAttribute('id', 'veo-trade-amount')
  var btcAmtInstructions = document.createElement("small");
  btcAmtInstructions.innerHTML = "Enter the amount of BTC you're supposed to be receiving";
  var btc_amount = input_text_maker(btcAmtInstructions, inputDiv);
  btc_amount.setAttribute('id', 'btc-trade-amount')
  inputDiv.innerHTML += "<br/>"

  var button = document.createElement("input");
  button.setAttribute('class', 'seller__step3-btn btn')
  button.type = "button";
  button.value = "Generate unsigned trade request";
  button.onclick = generate_unsigned_request;
  inputDiv.appendChild(button);


  function generate_unsigned_request(){
    variable_public_get(["height"], function(height) {
      variable_public_get(["pubkey"], function(server_pubkey) {
        var veo_amount = document.getElementById('veo-trade-amount')
        var btc_amount = document.getElementById('btc-trade-amount')
        var ba2 = Math.floor(parseFloat(btc_amount.value) * 100000000);
        var va2 = Math.floor(parseFloat(veo_amount.value) * 100000000);
        var request = [-7, 29, pubkey.value, height, btoa(bitcoin_address.value), veo_to.value, parseInt(time_limit.value), va2, ba2, server_pubkey];
        document.getElementById('seller__step3-unsigned').value = JSON.stringify(request);
      });
    });
  };
})();