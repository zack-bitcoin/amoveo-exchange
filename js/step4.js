(function(){
  // the step 4 container
  var div = document.createElement("div");
  div.setAttribute('class', 'seller__step4');
  div.innerHTML = "Copy the entire unsigned trade request generated above and sign it using the light wallet: http://159.65.120.84:8080/wallet.html"

  // heading for step 4
  var heading = document.createElement("h3");
  heading.innerHTML = "4. Sign trade request with the light wallet"

  // the container for sellers
  var sellerContainer = document.getElementsByClassName('seller')[0];
  sellerContainer.appendChild(heading);
  sellerContainer.appendChild(div);
})();