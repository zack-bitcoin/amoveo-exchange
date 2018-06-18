function showPagePart(id){
  var nodes = document.getElementsByClassName('container');
  for(var i = 0; i < nodes.length; i++) {
    nodes.item(i).style.display = "none";
  }
  var el = document.getElementById(id);
  el.style.display = "block";
}

(function(){
  var buyer = document.createElement('a');
  buyer.setAttribute('href', '#buyer');
  buyer.setAttribute('class', 'btn');
  buyer.innerText = "I'm buying VEO with BTC";
  var seller = document.createElement('a');
  seller.setAttribute('href', '#seller');
  seller.setAttribute('class', 'btn');
  seller.innerText = "I'm selling VEO";
  var header = document.getElementById('header');
  header.appendChild(buyer);
  header.appendChild(seller);

  buyer.addEventListener('click', function(e){
    var id = e.target.getAttribute('href');
    showPagePart(id.substring(1,id.length))
  });

  seller.addEventListener('click', function(e){
    var id = e.target.getAttribute('href');
    showPagePart(id.substring(1,id.length))
  });
})();