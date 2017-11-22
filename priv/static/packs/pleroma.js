//Add function to change toot button text
function changeTootBtn(){
    
    try {
        tootBtn = document.getElementsByClassName("button button--block");
        console.info(tootBtn);
        tootBtn[0].value = "Submit!";
        tootBtn[0].innerHTML = "Submit!";
    }
    catch(err) {
        //Repeat until we work...
        setTimeout(function(){ changeTootBtn(); }, 3000);
    }
    
    
}
//Run
changeTootBtn();