
function button_maker(val, fun, div) {
    var button = document.createElement("input");
    button.type = "button";
    button.value = translate.words(val);
    button.onclick = fun;
    div.append(button);
    return button;
}
function input_text_maker(instructions, div){
    if(typeof instructions !== 'object'){
        var veo_amount_info = document.createElement("h8");
        veo_amount_info.innerHTML = instructions;
    }
    div.append(veo_amount_info||instructions);
    var veo_amount = document.createElement("input");
    veo_amount.type = "text";
    div.append(veo_amount);
    return veo_amount;
}
