//Add function to change toot button text
function changeTootBtn(){
    tootBtn = document.getElementsByClassName("button button--block");
    console.info(tootBtn);
    tootBtn[0].value = "Submit!";
    tootBtn[0].innerHTML = "Submit!";
}
//Run
changeTootBtn();