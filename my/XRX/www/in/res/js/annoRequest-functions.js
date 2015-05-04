var api, error = 0, mouseAbsX, mouseAbsY, downTimer;

// *!* ################ helper- functions ################ *!*
// get the i18n messages
function geti18nText(lang, key){
    var breadcrump;
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/get-i18n-text?key="+key+"&amp;lang="+lang,false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 {
                 error = 0;
                 breadcrump = xmlhttp.responseText;
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   geti18nText(lang, key);
                 else
                   {
                   jQuery('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML= "Error! Please try again!";
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
     // return text of i18n message
     return breadcrump;
};

// zoom image on the request widget 
function requestZoom(type, id, idPrefix){
// remove the old image and create a new one with the new size
var newWidth, newHeight;
var parentID = idPrefix+"fields"+id;
if(idPrefix == "request")
  {
  var rid = "requestimg"+id;
  var queryid = "#requestimg"+id;
  var view = "views"+id;
  }
else if(idPrefix == "critic")
  {
  var rid = "criticimg"+id;
  var queryid = "#criticimg"+id;
  var view = "viewscritic"+id;
  } 
var src = document.getElementById(rid).getAttribute("SRC");
var oldWidth = jQuery(queryid).width();
var oldHeight = jQuery(queryid).height();
var img=document.createElement("IMG");
img.setAttribute('SRC', src); 
img.setAttribute('ID', rid);
jQuery(queryid).remove();
if (type == 'in')
   {
   newWidth = oldWidth * 1.5;
   newHeight = oldHeight * 1.5;
   }
else
   {
   newWidth = oldWidth / 1.5;
   newHeight = oldHeight / 1.5;
   }
document.getElementById(view).appendChild(img);
jQuery(queryid).width(newWidth);
jQuery(queryid).height(newHeight);
var multifactor = newWidth/oldWidth;
if(document.getElementById(parentID) != null)
			{
			var index = 0;
			var allFields = document.getElementById(parentID).childNodes;
			for(x=0;x<allFields.length;x++)
				{
			  if(allFields[x].nodeType == 1)
					index++;
			  }
			for(u=1;u<=index;u++)
				{
				var field = idPrefix+"annofield"+id+"-"+u;
				if(document.getElementById(field) != null)
			    {
					document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)*multifactor)+"px";
					document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)*multifactor)+"px";
					document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)*multifactor)+"px";        
					document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)*multifactor)+"px";
					}
				}
			}
};

// normalize coordinates of the direct annotations
function normCoordinates(idPrefix, number){
    // calculate the zooming factor
    var id = idPrefix+"img"+number;
    var jqueryID = '#'+id;
    var newImg = new Image();
    newImg.src = document.getElementById(id).src;
    jQuery(newImg).load(function(){
    var multifactor = newImg.width/jQuery(jqueryID).width();
    var parentID = idPrefix+"fields"+number;
		if(document.getElementById(parentID) != null)
			{
			var index = 0;
			var allFields = document.getElementById(parentID).childNodes;
			for(x=0;x<allFields.length;x++)
				{
			  if(allFields[x].nodeType == 1)
					index++;
			  }
			for(u=1;u<=index;u++)
				{
				var field = idPrefix+"annofield"+number+"-"+u;
				if(document.getElementById(field) != null)
			    {
					document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)/multifactor)+"px";
					document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)/multifactor)+"px";
					document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)/multifactor)+"px";        
					document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)/multifactor)+"px";
					}
				}
			}
    });
};

// move information tooltip to mouse position
function moveTooltip(e){
		// check if mousebutton is pressed more than 0.2 sec
		clearTimeout(downTimer);
		downTimer = setTimeout(function() {
        // Tooltip will follow the mouse pointer
		    toolinterval = window.setInterval(function() { moveTool(); }, 50);
		    // Calculate the position of the image tooltip
		    this.onmousemove = updateMouseAbsCoords;    
        }, 200);
}

// set coordinates of information tooltip
function moveTool(){
	jQuery('#tooltip').css({'top': mouseAbsY-15,'left': mouseAbsX-95});
}

// hide information tooltip
function stopTooltip(e){
    // Reset the z-index and hide the image tooltip
    clearTimeout(downTimer);
    clearInterval(toolinterval);
};

// update mouse coordination
function updateMouseAbsCoords(e) {
   mouseAbsX = e.pageX - $(document).scrollLeft(); 
   mouseAbsY = e.pageY - $(document).scrollTop();
};

// reset all areas of annotations
function resetAnnoFields(){
	// reset taskBar
	jQuery('#taskBar').css('display', 'block');
		// go through all privat annotations
    var all = document.getElementById("allRequests").childNodes;
    var number = 0;
    for(x=0;x<all.length;x++)
        {
        if(all[x].nodeType == 1)
             number++;
        }
    // reset area functions
    for(i=1;i<=number+1;i++)
        {
		    var parentID = "requestfields"+i;
        if(document.getElementById(parentID) != null)
        	{
        	var index = 0;
		      var allFields = document.getElementById(parentID).childNodes;
		      for(x=0;x<allFields.length;x++)
		         {
		         if(allFields[x].nodeType == 1)
		           index++;
		         }
		      var onmouseover = "", onmouseout = "";
		      for(p=1;p<=index;p++)
        				{
        				onmouseover = onmouseover+"jQuery('#requestannofield"+i+"-"+p+"').css('border-color','blue');";
              	onmouseout = onmouseout+"jQuery('#requestannofield"+i+"-"+p+"').css('border-color','#EF6A2F');";
        				}
		      for(u=1;u<=index;u++)
        			{
        		  var field = "requestannofield"+i+"-"+u;
        			if(document.getElementById(field) != null)
        				{
				        document.getElementById(field).setAttribute('onmouseover', onmouseover);
				        document.getElementById(field).setAttribute('onmouseout', onmouseout);
				        jQuery('#'+field).css('border-color','#EF6A2F');
				        }
			        }
	        }
        }
    
    // go through all public annotations
    var allpub = document.getElementById("allCritics").childNodes;
    var number = 0;
    for(x=0;x<allpub.length;x++)
        {
        if(allpub[x].nodeType == 1)
             number++;
        }
     // reset area functions
    for(i=1;i<=number+1;i++)
        {
		    var parentID = "criticfields"+i;
        if(document.getElementById(parentID) != null)
        	{
        	var index = 0;
		      var allFields = document.getElementById(parentID).childNodes;
		      for(x=0;x<allFields.length;x++)
		         {
		         if(allFields[x].nodeType == 1)
		           index++;
		         }
		      var onmouseover = "", onmouseout = "";
		      for(p=1;p<=index;p++)
        				{
        				onmouseover = onmouseover+"jQuery('#criticannofield"+i+"-"+p+"').css('border-color','blue');";
              	onmouseout = onmouseout+"jQuery('#criticannofield"+i+"-"+p+"').css('border-color','#EF6A2F');";
        				}
		      for(u=1;u<=index;u++)
        			{
				      var field = "criticannofield"+i+"-"+u;
				      if(document.getElementById(field) != null)
        				{
				        document.getElementById(field).setAttribute('onmouseover', onmouseover);
				        document.getElementById(field).setAttribute('onmouseout', onmouseout);
				        jQuery('#'+field).css('border-color','#EF6A2F');
				        }
			        }
	        }
        }
}

// close the information field an reset all configurations
function closeInfoField(){
jQuery('#tooltip').css('display', 'none');
resetAnnoFields();
}

// load the information toolbar of an annotation
function loadInfoTool(id, user, tagid, pubStatus, type, registerid, folio, lang){
	// ajax request to service
 	var xmlhttp;
  if (window.XMLHttpRequest)
     {// code for IE7+, Firefox, Chrome, Opera, Safari
     xmlhttp=new XMLHttpRequest();
     }
  else
     {// code for IE6, IE5
     xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
     }   
	if(type == 'request')     
  	xmlhttp.open("GET","anno/service/get-annotation-data?id="+id+"&user="+user+"&type=privat&registerid="+registerid+"&folio="+folio,true);
  else
  	xmlhttp.open("GET","anno/service/get-annotation-data?id="+id+"&user="+user+"&type=critic&registerid="+registerid+"&folio="+folio,true);
  xmlhttp.onreadystatechange=function(){
  if (xmlhttp.readyState==4)
     {
     if (xmlhttp.status==200)
        {
        // reset all annotation fields
        resetAnnoFields();
        
        var xmlDoc = xmlhttp.responseXML;
        // reset info tab - hide other interfaces and show display interface
        jQuery('#tooltip').css('display', 'block');
		    jQuery('#showInterface').css('display', 'block');
		    jQuery('#editInterface').css('display', 'none');
		    jQuery('#editSurfaceBar').css('display', 'none');
		    jQuery('#taskBar').css('display', 'block');
				jQuery('#editTaskBar').css('display', 'none');
        
        // load response data into tooltip field
        var category = xmlDoc.getElementsByTagName('category')[0].childNodes[0].nodeValue;
        var keyword, transcription;
        if(xmlDoc.getElementsByTagName('keyword')[0].hasChildNodes())
        	keyword = xmlDoc.getElementsByTagName('keyword')[0].childNodes[0].nodeValue;
        else
        	keyword = "";
        if(xmlDoc.getElementsByTagName('transcription')[0].hasChildNodes())
        	transcription = xmlDoc.getElementsByTagName('transcription')[0].childNodes[0].nodeValue;
        else
        	transcription = "";
        document.getElementById("category-content").innerHTML = category;
        document.getElementById("keyword-content").innerHTML = keyword;
        document.getElementById("transcription-content").innerHTML = transcription;
        if(type == 'request')
        	{
        	// define privat annotation configuration - functions/ buttons
		      var index = 0;
		      var parentID = "requestfields"+tagid;
		      var all = document.getElementById(parentID).childNodes;
		      for(x=0;x<all.length;x++)
		         {
		         if(all[x].nodeType == 1)
		            index++;
		         }
		      for(i=1;i<=index;i++)
        		 {
        		 var fieldID = 'requestannofield'+tagid+'-'+i;
        		 if(document.getElementById(fieldID) != null)
        				{
		        		 jQuery('#'+fieldID).css('border-color','blue');
		        		 document.getElementById(fieldID).setAttribute('onmouseover', '');
		        	   document.getElementById(fieldID).setAttribute('onmouseout', '');
		        	  }
        		 }
        	jQuery('#contributor-div').css('display', 'none');
          if(pubStatus == 'request' || pubStatus == 'accept')
        		{
        		jQuery('#taskBar').css('display', 'none');
        		}
        	else
        		{
	        	var editstring = "prepareEditAnno('"+id+"', '"+user+"', 'request', '"+lang+"', '"+registerid+"', '"+folio+"')";
	        	var editSurfacestring = "prepareEditSurface('"+id+"', '"+user+"', '"+tagid+"', 'request', '"+registerid+"', '"+folio+"', '"+lang+"')";
	        	var addstring = "prepareAddSurface('"+id+"', '"+user+"', '"+tagid+"', 'request', '"+registerid+"', '"+folio+"', '"+lang+"')";
	        	document.getElementById("editButton").setAttribute('ONCLICK', editstring);
	        	document.getElementById("editSurfaceButton").setAttribute('ONCLICK', editSurfacestring);
	        	document.getElementById("addButton").setAttribute('ONCLICK', addstring);
        		
        		// moderator functions
        		jQuery('#editButton').css('display', 'inline');
        		jQuery('#editSurfaceButton').css('display', 'inline');
        		jQuery('#addButton').css('display', 'inline');
        		jQuery('#taskBar').css('left', '105px');
        		}
        	}
        else
        	{
        	// define report annotation configuration - functions/ buttons/ contributor
        	var index = 0;
		      var parentID = "criticfields"+tagid;
		      var all = document.getElementById(parentID).childNodes;
		      for(x=0;x<all.length;x++)
		         {
		         if(all[x].nodeType == 1)
		            index++;
		         }
		      for(i=1;i<=index;i++)
        		 {
        		 var fieldID = 'criticannofield'+tagid+'-'+i;
        		 if(document.getElementById(fieldID) != null)
        				{
		        		 jQuery('#'+fieldID).css('border-color','blue');
		        		 document.getElementById(fieldID).setAttribute('onmouseover', '');
		        	   document.getElementById(fieldID).setAttribute('onmouseout', '');
		        	  }
        		 }
        	var contributor = xmlDoc.getElementsByTagName('contributor')[0].childNodes[0].nodeValue;
        	document.getElementById("contributor-content").innerHTML = contributor;
        	jQuery('#contributor-div').css('display', 'block');
        	jQuery('#taskBar').css('display', 'none');
        	}
        error = 0;
        }
    else
       {
       error++;
       if(error < 2)
          loadInfoTool(id, user, tagid, pubStatus, status, type, registerid, folio, lang);
       else
          {
          error = 0;
          }   
       }
    }
  }
  xmlhttp.send();
};

// has the user mark an image region 
function checkCoords(lang){
	   if (parseInt(jQuery('#w').val())==0) {
	       alert(geti18nText(lang, 'mark-a-region'));
	       return false;
	       }
	   else return true;       
    };

// calculate the zooming factor
function getImgSize(imgSrc, imgID){
        var size = jQuery('#'+imgID).width();
        var newImg = new Image();
        newImg.src = imgSrc;
        var width = newImg.width/size;
        return width;
    };

// *!* ################ Annotation requests functions ################ *!*
// prepare to edit surface of an annotation
function prepareEditSurface(id, user, tagid, type, registerid, folio, lang){
// hide edit Taskbar and show surface Taskbar
jQuery('#taskBar').css('display', 'none');
jQuery('#editSurfaceBar').css('display', 'block');
// count fields
if(type == "request")
	{
	var parentID = "requestfields"+tagid;
	}
var index = 0;
var allFields = document.getElementById(parentID).childNodes;
for(x=0;x<allFields.length;x++)
	 {
	 if(allFields[x].nodeType == 1)
		  index++;
	 }
// more than one field = only delete field/ on field left = delete annotation
if(index > 1) 
	{
	var deleteSurface = "prepareDeleteSurface('"+id+"', '"+user+"', '"+tagid+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
	document.getElementById("deleteSurface").setAttribute('ONCLICK', deleteSurface);
	jQuery('#editSurfaceBar').css('left', '100px');
	}
else
	{
	jQuery('#deleteSurface').css('display', 'none');
	jQuery('#editSurfaceBar').css('left', '110px');
	}
var back = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', 'decline','"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
var moveSurface = "prepareMoveSurface('"+id+"', '"+user+"', '"+tagid+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
document.getElementById("returnButton").setAttribute('ONCLICK', back);
document.getElementById("prepareEditSurface").setAttribute('ONCLICK', moveSurface);
};

// reset onlick function
function resetOnClick(id, user, tagid, type, registerid, folio, lang){
// define annotation surfaces - onmouseover/onmouseout
if(type == "request")
	{
	var parentID = "requestfields"+tagid;
	}
if(document.getElementById(parentID) != null)
   {
   var index = 0;
	 var allFields = document.getElementById(parentID).childNodes;
	 for(x=0;x<allFields.length;x++)
		  {
		  if(allFields[x].nodeType == 1)
		      index++;
		  }
		var onmouseover = "", onmouseout = "", onclick;
		for(p=1;p<=index;p++)
       {
       if(type == "request")
       	var field = "requestannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
        	{
        	 onmouseover = "";
		       onmouseout = "";
		       onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', 'decline', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
					 document.getElementById(field).setAttribute('onmouseover', onmouseover);
					 document.getElementById(field).setAttribute('onmouseout', onmouseout);
					 document.getElementById(field).setAttribute('onClick', onclick);
					}
       }
	 }
};

// prepare to define a new surface area
function prepareMoveSurface(id, user, tagid, type, registerid, folio, lang){
// define annotation surfaces - onmouseover/onmouseout
if(type == "request")
	{
	var parentID = "requestfields"+tagid;
	}
if(document.getElementById(parentID) != null)
   {
   var index = 0;
	 var allFields = document.getElementById(parentID).childNodes;
	 for(x=0;x<allFields.length;x++)
		  {
		  if(allFields[x].nodeType == 1)
		      index++;
		  }
		var onmouseover = "", onmouseout = "", onclick;
		for(p=1;p<=index;p++)
       {
       if(type == "request")
       	var field = "requestannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
         {
	       onmouseover = "jQuery('#"+field+"').css('border-color','red');";
	       onmouseout = "jQuery('#"+field+"').css('border-color','blue');";
	       onclick = "moveSurface('"+id+"', '"+user+"', '"+tagid+"', '"+field+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
				 document.getElementById(field).setAttribute('onmouseover', onmouseover);
				 document.getElementById(field).setAttribute('onmouseout', onmouseout);
				 document.getElementById(field).setAttribute('onClick', onclick);
				 }
       }
	 }
// define buttons and functions
jQuery('#editSurfaceBar').css('display', 'none');
jQuery('#editTaskBar').css('display', 'block');
jQuery('#editTaskBar').css('left', '60px');

var alertString = geti18nText(lang, 'please-select-surface');
var saveString = "alert('"+alertString+"');";
document.getElementById("addSurface").setAttribute('ONCLICK', saveString);
// cancel function on button
var cancelString = "cancelEditSurface('"+id+"', '"+user+"', '"+tagid+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"');";
document.getElementById("cancelEdit").setAttribute('ONCLICK', cancelString);
};

// move surface area
function moveSurface(id, user, tagid, field, type, registerid, folio, lang){
// save x and y values to indentify old surface object
if(type == "request")
	{
	var imgID = 'requestimg'+tagid;
	}
var multifactor = getImgSize(document.getElementById(imgID).src, imgID);
// hide old surface
jQuery('#'+field).css('display', 'none');
// save function on button
var saveString = "saveMove('"+id+"', '"+user+"', '"+tagid+"', '"+field+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
document.getElementById("addSurface").setAttribute('ONCLICK', saveString);
// get coords of field
var oldX = parseInt(jQuery('#'+field).css('left'));
var oldY = parseInt(jQuery('#'+field).css('top'));
var oldWidth = parseInt(jQuery('#'+field).css('width'));
var oldHeight = parseInt(jQuery('#'+field).css('height'));
var oldX2 = oldX + oldWidth;
var oldY2 = oldY + oldHeight;

// set Coords dummy input elements
jQuery('#x1').val(oldX);
jQuery('#y1').val(oldY);
jQuery('#x2').val(oldX2);
jQuery('#y2').val(oldY2);
jQuery('#w').val(oldWidth);
jQuery('#h').val(oldHeight);
	
	// create a new api object
	if(api==null)
	   {
	   // other function - button in Taskbar
		 api = jQuery.Jcrop('#'+imgID,{ 
		    bgColor: 'red', 
		    setSelect: [ oldX, oldY, oldX2, oldY2 ],
		    onChange: saveCoords,
				onSelect: saveCoords
		 	});
		 }
};

// save the new position coordinates of annotation surface
function saveMove(id, user, tagid, field, type, registerid, folio, lang){
	if(checkCoords(lang))
		{
		// get image informations - coordinates, src- code
		var surfaceID = document.getElementById(field).getAttribute('lang');
		if(type == "request")
			{
	  	var imgID = 'requestimg'+tagid;
	  	}
		var multifactor = getImgSize(document.getElementById(imgID).src, imgID);
	  var x1 = Math.round(parseInt(document.getElementById('x1').value));
	  var x2 = Math.round(parseInt(document.getElementById('h').value));
	  var y1 = Math.round(parseInt(document.getElementById('y1').value));
	  var y2 = Math.round(parseInt(document.getElementById('w').value));
	  var nx1 = Math.round(parseInt(document.getElementById('x1').value)*multifactor);
	  var ny1 = Math.round(parseInt(document.getElementById('y1').value)*multifactor);
	  var nx2 = Math.round(parseInt(document.getElementById('h').value)*multifactor);
	  var ny2 = Math.round(parseInt(document.getElementById('w').value)*multifactor);
	  // size is important to create an ID in DB
	  var size = ny2+nx2;
	  // define parameter string
	  var parameters = "x1="+nx1+"?!x2="+nx2+"?!y1="+ny1+"?!y2="+ny2+"?!size="+size+"?!registerid="+registerid+"?!folio="+folio+"?!surfaceID="+surfaceID+"?!";
	  var xmlhttp;
    // send request to annotation script
    if (window.XMLHttpRequest)
       {// code for IE7+, Firefox, Chrome, Opera, Safari
       xmlhttp=new XMLHttpRequest();
       }
    else
       {// code for IE6, IE5
       xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
       }
    xmlhttp.open("POST","anno/service/edit-request-surface?id="+id+"&user="+user+"&type=userrequest",true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
       {
       if (xmlhttp.status==200)
          { 
          var response = xmlhttp.responseText;
          // add surface on the screen
          if (response == "edit-surface")
              {      
              // define style and mouse actions
              var fieldstyle = "left:"+x1+"px;top:"+y1+"px;height:"+x2+"px;width:"+y2+"px;border-color:blue;";
              document.getElementById(field).setAttribute('style', fieldstyle);
						  jQuery('#'+field).css('display', 'block');
              
              // reset onClick event
              resetOnClick(id, user, tagid, type, registerid, folio, lang);
              
              // load data into editor
              loadInfoTool(id, user, tagid, 'decline', type, registerid, folio, lang);
              
							// show taskBar and hide editTaskBar
							jQuery('#taskBar').css('display', 'block');
							jQuery('#editTaskBar').css('display', 'none');
							jQuery('#editSurfaceBar').css('display', 'none');
							
							// show informations to user
              jQuery('#loadgif').css('display', 'none');
              document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
              
							// destroy the cropping function
						  api.destroy();
						  api = null;
              }
				  else
				      {
				      jQuery('#loadgif').css('display', 'none');
				      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
				      }    
          error = 0;
          }
       else
          {
          error++;
          if(error < 20)
            saveMove(id, user, tagid, field, type, registerid, folio, lang);
          else
            {
            jQuery('#loadgif').css('display', 'none');
            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
            error = 0;
            }    
          }
       }
    };
    xmlhttp.send(parameters);
	}
};

// cancel to edit a surface area
function cancelEditSurface(id, user, tagid, type, registerid, folio, lang){
// show taskBar and hide editTaskBar
jQuery('#taskBar').css('display', 'block');
jQuery('#editTaskBar').css('display', 'none');
jQuery('#editSurfaceBar').css('display', 'none');
jQuery('#addSurface').css('display', 'block');
// define annotation surfaces - onmouseover/onmouseout
if(type == "request")
	{
	var parentID = "requestfields"+tagid;
	}
if(document.getElementById(parentID) != null)
   {
   var index = 0;
	 var allFields = document.getElementById(parentID).childNodes;
	 for(x=0;x<allFields.length;x++)
		  {
		  if(allFields[x].nodeType == 1)
		      index++;
		  }
		for(p=1;p<=index;p++)
       {
       if(type == "request")
       	var field = "requestannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
         {
	       var  onmouseover = "", onmouseout = "", onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', 'decline', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
				 document.getElementById(field).setAttribute('onclick', onclick);
				 document.getElementById(field).setAttribute('onmouseover', onmouseover);
				 document.getElementById(field).setAttribute('onmouseout', onmouseout);
				 jQuery('#'+field).css('display', 'block');
				 }
       }
	 }
// destroy the cropping function
api.destroy();
api = null;
}

// prepare to delete a surface area
function prepareDeleteSurface(id, user, tagid, type, registerid, folio, lang){
// define annotation surfaces - onmouseover/onmouseout
if(type == "request")
	{
	var parentID = "requestfields"+tagid;
	}
if(document.getElementById(parentID) != null)
   {
   var index = 0;
	 var allFields = document.getElementById(parentID).childNodes;
	 for(x=0;x<allFields.length;x++)
		  {
		  if(allFields[x].nodeType == 1)
		      index++;
		  }
		var onmouseover = "", onmouseout = "";
		for(p=1;p<=index;p++)
       {
       if(type == "request")
       	var field = "requestannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
         {
	       var onmouseover = "jQuery('#"+field+"').css('border-color','red');";
	       var onmouseout = "jQuery('#"+field+"').css('border-color','blue');";
	       var onclick = "deleteSurface('"+id+"', '"+user+"', '"+tagid+"', '"+field+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
				 document.getElementById(field).setAttribute('onmouseover', onmouseover);
				 document.getElementById(field).setAttribute('onmouseout', onmouseout);
				 document.getElementById(field).setAttribute('onClick', onclick);
				 }
       }
	 }
// define buttons and functions
jQuery('#editSurfaceBar').css('display', 'none');
jQuery('#editTaskBar').css('display', 'block');
jQuery('#addSurface').css('display', 'none');
jQuery('#editTaskBar').css('left', '105px');

// cancel function on button
var cancelString = "cancelEditSurface('"+id+"', '"+user+"', '"+tagid+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"');";
document.getElementById("cancelEdit").setAttribute('ONCLICK', cancelString);
};

// delete a surface area
function deleteSurface(id, user, tagid, field, type, registerid, folio, lang){
// count fields
if(type == "request")
	{
	var parentID = "requestfields"+tagid;
	var imgID = 'requestimg'+tagid;
	}
var index = 0;
var allFields = document.getElementById(parentID).childNodes;
for(x=0;x<allFields.length;x++)
	 {
	 if(allFields[x].nodeType == 1)
		  index++;
	 }
// more than one field = only delete field/ on field left = delete annotation
if(index == 1) 
	{
	deletePublicAnno(id, lang, registerid, folio);
	}
else
	{
	// ask the user to confirm this step
  if(confirm(geti18nText(lang, 'delete-surface-question')))
    { 
		// ID to indentify old surface object
		var surfaceID = document.getElementById(field).getAttribute('lang');
		var multifactor = getImgSize(document.getElementById(imgID).src, imgID);
		var parameters = "registerid="+registerid+"?!folio="+folio+"?!surfaceID="+surfaceID+"?!";
		var xmlhttp;
		// send request to annotation script
		if (window.XMLHttpRequest)
		   {// code for IE7+, Firefox, Chrome, Opera, Safari
		   xmlhttp=new XMLHttpRequest();
		   }
		else
		   {// code for IE6, IE5
		   xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
		   }
		xmlhttp.open("POST","anno/service/delete-request-surface?id="+id+"&user="+user+"&type=userrequest",true);
		xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
		xmlhttp.onreadystatechange=function(){
		if (xmlhttp.readyState==4)
		   {
		   if (xmlhttp.status==200)
		      { 
		      var response = xmlhttp.responseText;
		      // delete surface on the screen
		      if (response == "delete-surface")
			         {  
			         jQuery('#'+field).css('display', 'none');  
			         document.getElementById(field).setAttribute("class", "");
			              
			         // show message
		           document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
			         }
					 else
							{
							document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
							}    
				   error = 0;
				   }
				else
				   {
				   error++;
				   if(error < 20)
				      deleteSurface(id, user, tagid, field, type, registerid, folio, lang)
				   else
				      {
				      jQuery('#loadgif').css('display', 'none');
				      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
				      error = 0;
				      }    
				   }
				}
		 };
		xmlhttp.send(parameters);
	 	}
	}
// show taskBar and hide editTaskBar
jQuery('#taskBar').css('display', 'block');
jQuery('#editTaskBar').css('display', 'none');
jQuery('#editSurfaceBar').css('display', 'none');
jQuery('#addSurface').css('display', 'block');
// reset onClick event
resetOnClick(id, user, tagid, type, registerid, folio, lang);
// load data into editor
loadInfoTool(id, user, tagid, 'decline', type, registerid, folio, lang);
};

// prepare to add a new surface to an annotation
function prepareAddSurface(id, user, tagid, type, registerid, folio, lang){
	// hide taskBar and show editTaskBar
	jQuery('#taskBar').css('display', 'none');
	jQuery('#editTaskBar').css('display', 'block');
	jQuery('#editTaskBar').css('left', '60px');
	
	// save and cancel function on buttons
	var saveString = "addSurface('"+id+"', '"+user+"', '"+tagid+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
	var cancelString = "cancelAdd();";
	document.getElementById("addSurface").setAttribute('ONCLICK', saveString);
	document.getElementById("cancelEdit").setAttribute('ONCLICK', cancelString);
	
	// reset Coords dummy input elements
	jQuery('#x1').val('0');
	jQuery('#y1').val('0');
	jQuery('#x2').val('0');
	jQuery('#y2').val('0');
	jQuery('#w').val('0');
	jQuery('#h').val('0');
	
	if(type == "request")
		{
		var imgID = '#requestimg'+tagid;
		}
	
	// create a new api object
	if(api==null)
	   {
	   // andere function - button im Taskbar
		 api = jQuery.Jcrop(imgID,{ 
		    bgColor: 'red', 
		    onChange: saveCoords,
				onSelect: saveCoords
		 	});
		 }
};

// add a new surface to an annotation
function addSurface(id, user, tagid, type, registerid, folio, lang){
	if(checkCoords(lang))
		{
		// get image informations - coordinates, src- code
	  if(type == "request")
			{
	  	var imgID = 'requestimg'+tagid;
	  	}
		var multifactor = getImgSize(document.getElementById(imgID).src, imgID);
	  var x1 = Math.round(parseInt(document.getElementById('x1').value));
	  var x2 = Math.round(parseInt(document.getElementById('h').value));
	  var y1 = Math.round(parseInt(document.getElementById('y1').value));
	  var y2 = Math.round(parseInt(document.getElementById('w').value));
	  var nx1 = Math.round(parseInt(document.getElementById('x1').value)*multifactor);
	  var ny1 = Math.round(parseInt(document.getElementById('y1').value)*multifactor);
	  var nx2 = Math.round(parseInt(document.getElementById('h').value)*multifactor);
	  var ny2 = Math.round(parseInt(document.getElementById('w').value)*multifactor);
	  // size is important to create an ID in DB
	  var size = ny2+nx2;
	  // define parameter string
	  var parameters = "x1="+nx1+"?!x2="+nx2+"?!y1="+ny1+"?!y2="+ny2+"?!size="+size+"?!registerid="+registerid+"?!folio="+folio+"?!";
	  var xmlhttp;
    // send request to annotation script
    if (window.XMLHttpRequest)
       {// code for IE7+, Firefox, Chrome, Opera, Safari
       xmlhttp=new XMLHttpRequest();
       }
    else
       {// code for IE6, IE5
       xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
       }
    xmlhttp.open("POST","anno/service/add-request-surface?id="+id+"&user="+user+"&type=userrequest",true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
       {
       if (xmlhttp.status==200)
          { 
          var response = xmlhttp.responseText;
          // add surface on the screen
          if (response == "add-surface")
              {     
		          // define ID because of existing elements
		          var index = 0;
		          if(type == "request")
								{
								var parentID = "requestfields"+tagid;
								}
		          var all = document.getElementById(parentID).childNodes;
		          for(x=0;x<all.length;x++)
		             {
		             if(all[x].nodeType == 1)
		               index++;
		             }
		          var fieldIdNumber = index+1;
		          
		          var onmouseover = "", onmouseout = "";
                    
              // functions
              var onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', 'decline', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
                    
              // define style and mouse actions
              if(type == "request")
			       		var fieldid = "requestannofield"+tagid+"-"+fieldIdNumber;
              var fieldstyle = "left:"+x1+"px;top:"+y1+"px;height:"+x2+"px;width:"+y2+"px;border-color:blue;";
                    
              var surfaceID = nx1 +''+ nx2 +''+ ny1 +''+ ny2 +''+ size;      
              // create annotationfield
              var annofield = document.createElement("div");
              annofield.setAttribute('CLASS', 'direct');
              annofield.setAttribute('ID', fieldid);
              annofield.setAttribute('STYLE', fieldstyle);
              annofield.setAttribute('lang', surfaceID);
              annofield.setAttribute('onmouseover', onmouseover);
              annofield.setAttribute('onmouseout', onmouseout); 
							annofield.setAttribute('onClick', onclick);      
              
              // add surface to annotation div
              document.getElementById(parentID).appendChild(annofield);
                    
              // add new tags to existing elements
              jQuery('#loadgif').css('display', 'none');
              document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                    
              // load data into editor
              if(type == 'request')
                loadInfoTool(id, user, tagid, 'decline', 'request', registerid, folio, lang);
              // hide taskBar and show editTaskBar
							jQuery('#taskBar').css('display', 'block');
							jQuery('#editTaskBar').css('display', 'none');
							jQuery('#'+field).css('display', 'block');
							// destroy the cropping function
						  api.destroy();
						  api = null;
              }
				  else
				      {
				      jQuery('#loadgif').css('display', 'none');
				      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
				      }    
          error = 0;
          }
       else
          {
          error++;
          if(error < 20)
            addSurface(id, user, tagid, type, registerid, folio, lang);
          else
            {
            jQuery('#loadgif').css('display', 'none');
            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
            error = 0;
            }    
          }
       }
    };
    xmlhttp.send(parameters);
	}
};

// save coordinates to dummy fields
function saveCoords(c){
	jQuery('#x1').val(c.x);
	jQuery('#y1').val(c.y);
	jQuery('#x2').val(c.x2);
	jQuery('#y2').val(c.y2);
	jQuery('#w').val(c.w);
	jQuery('#h').val(c.h);
};

// cancel the process to add a new surface to an annotation
function cancelAdd(){
	// show taskBar and hide editTaskBar
	jQuery('#taskBar').css('display', 'block');
	jQuery('#editTaskBar').css('display', 'none');
	jQuery('#editSurfaceBar').css('display', 'none');
	jQuery('#addSurface').css('display', 'block');
	// destroy the cropping function
  api.destroy();
  api = null;
}

// prepare to edit an annotationtext
function prepareEditAnno(id, user, type, lang, registerid, folio){
    //define save string
    var updatestring = "updateAnno('"+id+"', '"+user+"', '"+type+"', '"+lang+"', '"+registerid+"', '"+folio+"');";
    document.getElementById('saveanno').removeAttribute('ONCLICK');
    document.getElementById('saveanno').setAttribute('ONCLICK', updatestring)
    
    // show edit interface and hide display interface
    jQuery('#showInterface').css('display', 'none');
    jQuery('#editInterface').css('display', 'block');
    
    // load current data into input fields
    jQuery('#keyword').val(jQuery('#keyword-content').text());
    jQuery('#transcription').val(jQuery('#transcription-content').text());
    jQuery("select#category > option").removeAttr('selected');
    document.getElementById(jQuery('#category-content').text()).setAttribute('selected', 'selected');
}

// edit an annotationtext in the DB
function updateAnno(id, user, type, lang, registerid, folio){
        var transcription = jQuery('#transcription').val();
        var keyword = jQuery('#keyword').val();
        var category = jQuery('#category').val();
        // check for the user's input
        if (transcription == '' || category == '')
            {
            alert(geti18nText(lang, 'please-insert-an-annotation'));
            }
        else
        {
        var parameters = "?!category="+category+"?!keyword="+keyword+"?!transcription="+transcription+"?!registerid="+registerid+"?!folio="+folio+"?!";
        // send request to crop script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            } 
        if(type == 'request') 
                xmlhttp.open("POST","anno/service/edit-request-annotation?user="+user+"&id="+id+"&type=userrequest",true);
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                    // show display interface
	                  jQuery('#showInterface').css('display', 'block');
			    				  jQuery('#editInterface').css('display', 'none');
			    				  
			    				  // reset edit- interface
	                  jQuery('#keyword').val('');
	                  jQuery('#transcription').val('');
	                  
	                  // update the text of the annotationfield
                    document.getElementById("category-content").innerHTML = category;
				            document.getElementById("keyword-content").innerHTML = keyword;
				            document.getElementById("transcription-content").innerHTML = transcription;
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        updateAnno(id, user, type, lang, registerid, folio);
                    else
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        error = 0;
                        } 
                 }
              }
      else { 
           jQuery('#loading').css('display', 'block');
           document.getElementById("loadtext").innerHTML = geti18nText(lang, 'updating-data');
           }
        };
        xmlhttp.send(parameters);
     }   
    };

// show the request informations for the moderator or user
function showRequest(status, dataid, requestid, user, stype, lang){
   if(stype == "request")
      {
      var field = '#field'+requestid;
      var request = 'request'+requestid;
      var queryid = '#request'+requestid;
      var arrow = 'arrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"', '"+user+"', 'request', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"', '"+user+"', 'request', '"+lang+"');";
      }
   else if(stype == "critic")
      {
      var field = '#fieldcritic'+requestid;
      var request = 'requestcritic'+requestid;
      var queryid = '#requestcritic'+requestid;
      var arrow = 'arrowcritic'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"', '"+user+"', 'critic', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"', '"+user+"', 'critic', '"+lang+"');";
      }
   else if(stype == "report")
      {
      var field = '#repfield'+requestid;
      var request = 'report'+requestid;
      var queryid = '#report'+requestid;
      var arrow = 'reparrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"', '"+user+"', 'report', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"', '"+user+"', 'report', '"+lang+"');";
      }
   if(status=="start")
   {
     // show the information- field
     jQuery(field).css('display', 'block');
     jQuery(queryid).css('-moz-border-radius', '10px 10px 0px 0px');
     jQuery(queryid).css('-khtml-border-radius', '10px 10px 0px 0px');
     jQuery(queryid).css('-webkit-border-radius', '10px 10px 0px 0px');
     jQuery(queryid).css('border-radius', '10px 10px 0px 0px');
     document.getElementById(request).removeAttribute('ONCLICK');
     document.getElementById(request).setAttribute('ONCLICK', shonlick);     
     document.getElementById(arrow).removeAttribute('SRC');
     document.getElementById(arrow).setAttribute('SRC', '/in/minus.png');
     if(stype == "request")
              {
              normCoordinates("request", requestid);
              }
     else if(stype == "critic")
             {
             normCoordinates("critic", requestid);
             }
     else if(stype == "report")
             {
             normCoordinates("rep", requestid);
             }  
   }
   else if(status=="hide")
   {
     // show the information- field
     jQuery(field).css('display', 'block');
     jQuery(queryid).css('-moz-border-radius', '10px 10px 0px 0px');
     jQuery(queryid).css('-khtml-border-radius', '10px 10px 0px 0px');
     jQuery(queryid).css('-webkit-border-radius', '10px 10px 0px 0px');
     jQuery(queryid).css('border-radius', '10px 10px 0px 0px');
     document.getElementById(request).removeAttribute('ONCLICK');
     document.getElementById(request).setAttribute('ONCLICK', shonlick);     
     document.getElementById(arrow).removeAttribute('SRC');
     document.getElementById(arrow).setAttribute('SRC', '/in/minus.png');
   }
   else
   {
     // hide the information- field
     jQuery(field).css('display', 'none');
     jQuery(queryid).css('-moz-border-radius', '10px 10px 10px 10px');
     jQuery(queryid).css('-khtml-border-radius', '10px 10px 10px 10px');
     jQuery(queryid).css('-webkit-border-radius', '10px 10px 10px 10px');
     jQuery(queryid).css('border-radius', '10px 10px 10px 10px');
     document.getElementById(request).removeAttribute('ONCLICK');
     document.getElementById(request).setAttribute('ONCLICK', honlick);     
     document.getElementById(arrow).removeAttribute('SRC');
     document.getElementById(arrow).setAttribute('SRC', '/in/plus.png');
   }
}

// user stops a publication process
function stopPublication(dataid, requestid, user, lang, registerid, folio){
    // send request to compare script
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/stop-publication?id="+dataid+"&user="+user+"&folio="+folio+"&registerid="+registerid, true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      // delete request in open-request-list
                      var deleteid = "request"+requestid;
                      var fieldid = "field"+requestid;
                      document.getElementById(deleteid).style.display = "none";
                      document.getElementById(fieldid).style.display = "none";
                        
                      // hide and reset tooltip
                      closeInfoField();
										  jQuery('#tooltip').css('top', '200');
										  jQuery('#tooltip').css('left', '200');
                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   stopPublication(dataid, requestid, user, lang, registerid, folio);
                 else
                   {
                   jQuery('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
}

// user send again a publication request to a moderator 
function sendBackToModerator(dataid, requestid, user, lang, registerid, folio){
    var comment = jQuery('#input'+requestid).val();
    // send request to compare script
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("POST","service/resend-request?id="+dataid+"&user="+user+"&folio="+folio+"&registerid="+registerid, true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      var buttonID = '#requestButton'+requestid;
                      var commentID = '#comments'+requestid;
                      var fieldID = '#field'+requestid;
                      var statusID = 'status'+requestid;
                      var queryStatusID = '#status'+requestid;
                      // delete request in open-request-list
                      jQuery(buttonID).css('display', 'none');
                      jQuery(commentID).css('display', 'none');
                      jQuery(fieldID).css('height', '390');
                      document.getElementById(statusID).innerHTML = "Status: "+geti18nText(lang, 'wait-for-release');
                      jQuery(queryStatusID).css('color', 'blue');
                      var parentID = "requestfields"+requestid;
											if(document.getElementById(parentID) != null)
											   {
											   var index = 0;
												 var allFields = document.getElementById(parentID).childNodes;
												 for(x=0;x<allFields.length;x++)
													  {
													  if(allFields[x].nodeType == 1)
													      index++;
													  }
													var onclick;
													for(p=1;p<=index;p++)
											       {
											       var field = "requestannofield"+requestid+"-"+p;
											       if(document.getElementById(field) != null)
											        	{
													       onclick = "loadInfoTool('"+dataid+"', '"+user+"', '"+requestid+"', 'request', 'request', '"+registerid+"', '"+folio+"', '"+lang+"')";
																 document.getElementById(field).setAttribute('onClick', onclick);
																}
											       }
												 }
                      loadInfoTool(dataid, user, requestid, 'request', 'request', registerid, folio, lang)
                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   sendBackToModerator(dataid, requestid, user, lang, registerid, folio);
                 else
                   {
                   jQuery('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send(comment);
};

// user send again a publication request to a moderator 
function resendReport(dataid, requestid, user, lang, registerid, folio){
    var comment = jQuery('#criticinput'+requestid).val();
    // send request to compare script
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("POST","service/resend-report?id="+dataid+"&user="+user+"&folio="+folio+"&registerid="+registerid, true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      var editareaID = '#editarea'+requestid;
                      var commentID = '#criticcomment'+requestid;
                      var fieldID = '#fieldcritic'+requestid;
                      var queryStatusID = '#criticstatus'+requestid;
                      // delete request in open-request-list
                      jQuery(editareaID).css('display', 'none');
                      jQuery(commentID).text(comment);
                      jQuery(fieldID).css('height', '500');
                      jQuery(queryStatusID).text("Status: "+geti18nText(lang, 'wait-for-answer'));
                      jQuery(queryStatusID).css('color', 'blue');
                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   resendReport(dataid, requestid, user, lang, registerid, folio);
                 else
                   {
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send(comment);
};

// hide the annotation request in the request list
function hideRequest(dataid, requestid, user, lang, registerid, folio){
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/delete-private-annotation?id="+dataid+"&user="+user+"&registerid="+registerid+"&folio="+folio, true);
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                        // delete request in open-request-list
                        var deleteid = "request"+requestid;
                        var fieldid = "field"+requestid;
                        document.getElementById(deleteid).style.display = "none";
	                      document.getElementById(fieldid).style.display = "none";
	                        
	                      // hide and reset tooltip
	                      closeInfoField();
											  jQuery('#tooltip').css('top', '200');
											  jQuery('#tooltip').css('left', '200');
	                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   hideRequest(dataid, requestid, user, lang, registerid, folio);
                 else
                   {
                   jQuery('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
}

// hide the annotation report in the report list
function hideReport(dataid, requestid, user, lang, registerid, folio){
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/delete-report-annotation?id="+dataid+"&user="+user+"&registerid="+registerid+"&folio="+folio, true);
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                        // delete request in open-request-list
                        var deleteid = "requestcritic"+requestid;
                        var fieldid = "fieldcritic"+requestid;
                        document.getElementById(deleteid).style.display = "none";
	                      document.getElementById(fieldid).style.display = "none";
	                        
	                      // hide and reset tooltip
	                      closeInfoField();
											  jQuery('#tooltip').css('top', '200');
											  jQuery('#tooltip').css('left', '200');
	                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   hideReport(dataid, requestid, user, lang, registerid, folio);
                 else
                   {
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
};
