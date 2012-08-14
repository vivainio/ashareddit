// JavaScript Document
window.onload = function(){
	
	// ui-subpage fix
	var list = s('ui-subpage-leaf');
	if(list !== undefined && list.length){
		for(var i=0, j=list.length; i <j;  i++){
				var w = list[i].clientWidth;
				list[i].style.cssText = "width: "+w+"px; float:left;";
		}
		list[0].parentElement.style.cssText = "width: "+(w * list.length)+"px;";
	}	
/*
	// ui-tab fix
	var list = s('ui-tab-content-row');
	if(list !== undefined && list.length){
		for(var i=0, j=list.length; i <j;  i++){
			if(list[i].children){
				var w = list[i].clientWidth;
				for(var k=0, l=list[i].children.length; k<l; k++){
					list[i].children[k].style.cssText = "width: "+w+"px; float:left;";
				}
				console.info("width: "+( w * list[i].length)+"px;");
				list[i].style.cssText = "width: "+( w * list[i].children.length)+"px;overflow:hidden;";
			}
		}
	}
*/	
};

function s(name){
	try{
		return document.getElementsByClassName(name);
	}catch(e){ return undefined; }
}
