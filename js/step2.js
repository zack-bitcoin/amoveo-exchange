(function(){
  // the step 2 container
  var div = document.createElement("div");
  div.setAttribute('class', 'seller__step2');
  div.innerHTML = "Go check http://veoscan.io/blocks after you deposit and wait for 4 blocks from that block."

  // heading for step 2
  var heading = document.createElement("h3");
  heading.innerHTML = "2. Wait for 4 confirmations"

  // the container for sellers
  var sellerContainer = document.getElementsByClassName('seller')[0];
  sellerContainer.appendChild(heading);
  sellerContainer.appendChild(div);
})();