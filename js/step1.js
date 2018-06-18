(function(){
  // the step 1 container
  var div = document.createElement("div");
  div.setAttribute('class', 'seller__step1');

  // left side
  var inputDiv = document.createElement("div");
  inputDiv.setAttribute('class', 'seller__step1-input');
  div.appendChild(inputDiv);

  // heading for step 1
  var heading = document.createElement("h3");
  heading.innerHTML = "1. Start by putting your VEO in escrow"

  // the container for sellers
  var sellerContainer = document.getElementsByClassName('seller')[0];
  sellerContainer.appendChild(heading);
  sellerContainer.appendChild(div);

  // instructions + input
  var instructions = document.createElement("small");
  instructions.innerHTML = "Enter the amount of VEO you wish to sell";
  var amt = input_text_maker(instructions, inputDiv);

  // right side and end of step 1 instructions
  var toSendDiv = document.createElement("div");
  toSendDiv.setAttribute('class', 'seller__step1-to-send');
  div.appendChild(toSendDiv);

  amt.addEventListener('change', function(e){
    // deposit fee is currently 0.0007 VEO. 
    // trade fee is 0.05 VEO. 
    // If the bitcoin doesn't arrive withing the time limit, 
    // then the trade is refunded, you get 0.03 VEO of the fee back. 
    var amountEntered = +(e.target.value);
    var depositFee = 0.0007;
    var tradeFee = 0.05;
    var amountToSend = amountEntered+depositFee+tradeFee;
    variable_public_get(["pubkey"], function(pub) {
      toSendDiv.innerHTML = "Please deposit "+amountToSend+" VEO to "+pub;
      toSendDiv.innerHTML += "<br/><br/><small> <strong>Why?</strong> Deposit fee is currently 0.0007 VEO. trade fee is 0.05 VEO. If the bitcoin doesn't arrive withing the time limit, then the trade is refunded, you get 0.03 VEO of the fee back. </small>";
      document.getElementById('veo-trade-amount').value = amountToSend;
    });
  })
})();