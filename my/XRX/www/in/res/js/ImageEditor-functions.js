var api, workmode="Viewmode", error = 0, saveoption = "new", opened = 'close', mouseAbsX, mouseAbsY, downTimer;
// api is the jcrop object, mode is the chartercontext, error is used for IE, saveoption for save- context and opened is used for toolbar

// *!* ################ HELPER functions in Image- Viewport ################ *!*

// on load functions
jQuery(function() {
                    // set position of page elements (it has to be defined as a result of the fullscreen mode)
                    var width = screen.width;
                    var closeMargin = (width/2)-100;
                    var pushMargin = (width/2)-55;
                    var funcMargin = (width/2)-400;
                    var viewportHeight = (document.body.offsetHeight)-82;
                    jQuery('#viewport').css('height', viewportHeight);
                    jQuery('#mode').css('left', closeMargin);
                    jQuery('#pushDiv').css('left', pushMargin);
                    jQuery('#functionField').css('left', funcMargin);
                    // init annotations
                    loadCoordinates();
                });

                
// change image of viewport
function changeImage(url){
	document.images["image"].src = url;
	document.getElementById('imgContainer').setAttribute('href', url);
}
                
// fade in load- div                
function loadFadeIn(){
    jQuery("#loading").animate({
        "marginTop": 51
        });
}

// fade out load- div   
function loadFadeOut(){
    jQuery("#loading").animate({
        "marginTop": 0
        });
}

// define position of function field
function checkImgWidth(){
    var width = jQuery('#img').width();
    // if image is to large for viewport, the function field has to be moved upwards (otherwise it will block the scrollbar)
    if(width > screen.width)
            {
            jQuery('#pushDiv').css('bottom', '13px');
            jQuery('#functionField').css('bottom', '13px');
            }                            
    else    
            {
            jQuery('#pushDiv').css('bottom', '0');
            jQuery('#functionField').css('bottom', '0');
            }
}

// open or close function field  
function changeFuncField(){
    // check if field is opened
    if(opened == 'close')
        {
        checkImgWidth();
        jQuery('#functionField').css('overflow', 'hidden');
        // show toolbar
        jQuery("#pushDiv").animate({
                    "marginBottom": 46
            });
        jQuery("#functionField").animate({
                "height": 45
            });
        // define next state - show save editor or close Functionfield onClick
        if(jQuery('#cropeditor').css('display')=='block')
            {   
            opened = 'savefield';
            }
        else
            {
            // only show toolbar
            document.getElementById("pushImg").setAttribute('SRC', '/in/push_down.png');
            opened = 'open';
            }
        }
    else if(opened == 'savefield')
        {
        // show save editor and define next state to close
        jQuery('#functionField').css('overflow', 'auto');
        document.getElementById("pushImg").setAttribute('SRC', '/in/push_down.png');
        opened = 'open';
        jQuery("#pushDiv").animate({
                    "marginBottom": 320
            });
        jQuery("#functionField").animate({
                "height": 320
            });
        }
    else
        {
        // close func field
        document.getElementById("pushImg").setAttribute('SRC', '/in/push_up.png');
        opened = 'close';
        jQuery("#pushDiv").animate({
             "marginBottom": 0
        });
        jQuery("#functionField").animate({
             "height": 0
        });
        }
        
}
           
// zoom image on the ImageEditor widget 
function zoom(type){
        // api has to be destroyed to get the control about the image
        if(api!=null)
            {
            api.destroy();
            }
        // remove the old image and create a new one with the new size
        var newwidth, newheight;
        var src = document.getElementById("img").getAttribute("SRC");
        var oldwidth = jQuery('#img').width();
        var oldheight = jQuery('#img').height();
        var img=document.createElement("IMG");
        img.setAttribute('SRC', src); 
        img.setAttribute('ID', "img");
        img.setAttribute('NAME', "image");
        jQuery('#img').remove();
        if (type == 'in')
            {
            newwidth = oldwidth * 1.5;
            newheight = oldheight * 1.5;
            
            }
        else
            {
            newwidth = oldwidth / 1.5;
            newheight = oldheight / 1.5;
            }
        document.getElementById("imgContainer").appendChild(img);
        jQuery('#img').width(newwidth);
        jQuery('#img').height(newheight);
        checkImgWidth();
        // activate Jcrop again
        var selectionArray = new Array();
        var multifactor = newwidth/oldwidth;
        jQuery('#x1').val(Math.round(parseInt(jQuery('#x1').val())*multifactor));
        jQuery('#y1').val(Math.round(parseInt(jQuery('#y1').val())*multifactor));
        jQuery('#x2').val(Math.round(parseInt(jQuery('#x2').val())*multifactor));
        jQuery('#y2').val(Math.round(parseInt(jQuery('#y2').val())*multifactor));
        jQuery('#w').val(Math.round(parseInt(jQuery('#w').val())*multifactor));
        jQuery('#h').val(Math.round(parseInt(jQuery('#h').val())*multifactor));
        
        selectionArray[0] = jQuery('#x1').val();
        selectionArray[1] = jQuery('#y1').val();
        selectionArray[2] = jQuery('#x2').val();
        selectionArray[3] = jQuery('#y2').val();
        if(api!=null)
            {       
            api = jQuery.Jcrop('#img',{ 
	           bgColor: 'red', 
	           setSelect: selectionArray,
	           onChange: showCoords,
			   onSelect: showCoords
	        });
	        }
	     // reprint the annotations
        reprintAnnos(newwidth, oldwidth);
    };

// start Jcrop and the function to mark an image region
function startCrop(){
       workmode = "Selectmode";
       jQuery('#viewmode').css('display', 'inline');
       jQuery('#selectmode').css('display', 'none');
       jQuery('#directselected').css('display', 'none');
		   jQuery('#img-link').click(function(e) {e.preventDefault();});
		   // create a new api object
		   if(api==null)
	            {
		        api = jQuery.Jcrop('#img',{ 
		           bgColor: 'red', 
		           onChange: showCoords,
				   		 onSelect: showCoords
		           });
		        }
};

// cancel the activation of the cropping tools
function viewmode(){
    jQuery('#selectmode').css('display', 'block');
    jQuery('.hiddenButton').css('display', 'none');
    jQuery('#viewmode').css('display', 'none');
    jQuery('#directselected').css('display', 'none');
    jQuery('#annotationfield').val('');
    workmode = "Viewmode";
    opened = 'open';
    document.getElementById("pushImg").setAttribute('SRC', '/in/push_down.png');
    jQuery('#functionField').css('overflow', 'hidden');
    jQuery("#pushDiv").animate({
           "marginBottom": 45
        });
        jQuery("#functionField").animate({
             "height": 45
        });
    jQuery('#cropeditor').css('display', 'none');
    // destroy the cropping function
    api.destroy();
    api = null;
};

// save the coordinates to input fields
function showCoords(c){
	  jQuery('#x1').val(c.x);
		jQuery('#y1').val(c.y);
		jQuery('#x2').val(c.x2);
		jQuery('#y2').val(c.y2);
		jQuery('#w').val(c.w);
		jQuery('#h').val(c.h);
		jQuery('.hiddenButton').css('display', 'inline'); 
        workmode = "Editmode";
};

 // normalize coordinates of the direct annotations
function loadCoordinates(){
    // calculate the zooming factor
    var newImg = new Image();
    newImg.src = document.getElementById('img').src;
    jQuery(newImg).load(function(){
        var multifactor = newImg.width/jQuery('#img').width();
        // go through all privat annotations
        var all = document.getElementById("privatAnnos").childNodes;
        var number = 0;
        for(x=0;x<all.length;x++)
            {
            if(all[x].nodeType == 1)
                 number++;
            }
          
        // calculate the new coordinates
        for(i=1;i<=number;i++)
            {
            var parentID = "privatfields"+i;
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
						      var field = "directannofield"+i+"-"+u;
						      if(document.getElementById(field) != null)
        						{
						        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)/multifactor)+"px";
						        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)/multifactor)+"px";
						        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)/multifactor)+"px";        
						        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)/multifactor)+"px";
						        }
					       }
				       }
            }
        // go through all public annotations
        var allpub = document.getElementById("publicAnnos").childNodes;
        var number = 0;
        for(x=0;x<allpub.length;x++)
            {
            if(allpub[x].nodeType == 1)
                 number++;
            }
        // calculate the new coordinates
        for(i=1;i<=number;i++)
            {
            var parentID = "publicfields"+i;
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
						      var field = "pubannofield"+i+"-"+u;
						      if(document.getElementById(field) != null)
        						{
						        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)/multifactor)+"px";
						        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)/multifactor)+"px";
						        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)/multifactor)+"px";        
						        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)/multifactor)+"px";
						        }
					       }
				       }
            }
    });
    }

// has the user mark an image region 
function checkCoords(lang){
	   if (parseInt(jQuery('#w').val())==0) {
	       alert(geti18nText(lang, 'mark-a-region'));
	       return false;
	       }
	   else return true;       
    };

// calculate the zooming factor
function getImgSize(imgSrc){
        var size = jQuery('#img').width();
        var newImg = new Image();
        newImg.src = imgSrc;
        var width = newImg.width/size;
        return width;
    };

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
    xmlhttp.open("GET","../service/get-i18n-text?key="+key+"&amp;lang="+lang,false);
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
                   loadFadeIn();
                   document.getElementById("loadtext").innerHTML= "Error! Please try again!";
                   window.setTimeout(loadFadeOut,10000);
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
     // return text of i18n message
     return breadcrump;
};

// show help texts
function showHelp(e, lang){
    // may be store chartercontext - font/ collection
    var send = "no";
    var width = screen.width;
    var x = e.pageX-40;
    var y = e.pageY;
    // define position auf booble div 
    if(workmode == "Viewmode")
    {
    var key = "viewmode-text";
    var height = "140px";
    var topcorner = "180px";
    y = y-200;
    send = "yes";
    }
    else if(workmode == "Selectmode")
    {
    var key = "selectmode-text";
    var height = "100px";
    y = y-180;
    var topcorner = "140px";
    send = "yes";
    }
    else if(workmode == "Editmode")
    {
    var key = "editmode-text";
    var height = "140px";
    y = y-200;
    var topcorner = "180px";
    send = "yes";
    }
    if(send == "yes")
    {
     jQuery('#bobble').css('display', 'block');
     jQuery('#bobble').css('height', height);
     jQuery('#bobble').css('top', y); 
     jQuery('#bobblecorner').css('top', topcorner); 
     jQuery('#bobble').css('left', x);    
     document.getElementById('bobbletext').innerHTML = geti18nText(lang, key);
    };
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
	jQuery('#wfR').css('display', 'none');
		// go through all privat annotations
    var all = document.getElementById("privatAnnos").childNodes;
    var number = 0;
    for(x=0;x<all.length;x++)
        {
        if(all[x].nodeType == 1)
             number++;
        }
    // reset area functions
    for(i=1;i<=number+1;i++)
        {
		    var parentID = "privatfields"+i;
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
        				onmouseover = onmouseover+"jQuery('#directannofield"+i+"-"+p+"').css('border-color','blue');";
              	onmouseout = onmouseout+"jQuery('#directannofield"+i+"-"+p+"').css('border-color','#EF6A2F');";
        				}
		      for(u=1;u<=index;u++)
        			{
        		  var field = "directannofield"+i+"-"+u;
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
    var allpub = document.getElementById("publicAnnos").childNodes;
    var number = 0;
    for(x=0;x<allpub.length;x++)
        {
        if(allpub[x].nodeType == 1)
             number++;
        }
     // reset area functions
    for(i=1;i<=number+1;i++)
        {
		    var parentID = "publicfields"+i;
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
        				onmouseover = onmouseover+"jQuery('#pubannofield"+i+"-"+p+"').css('border-color','blue');";
              	onmouseout = onmouseout+"jQuery('#pubannofield"+i+"-"+p+"').css('border-color','#EF6A2F');";
        				}
		      for(u=1;u<=index;u++)
        			{
				      var field = "pubannofield"+i+"-"+u;
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
var onmouseover = "jQuery('.direct').css('display', 'block');", onmouseout = "jQuery('.direct').css('display', 'none');";
document.getElementById('viewport').setAttribute('onmouseover', onmouseover);
document.getElementById('viewport').setAttribute('onmouseout', onmouseout);
jQuery('#tooltip').css('display', 'none');
resetAnnoFields();
}

// load the information toolbar of an annotation
function loadInfoTool(id, user, tagid, role, type, registerid, folio, lang){
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
  xmlhttp.open("GET","../service/get-annotation-data?id="+id+"&user="+user+"&type="+type+"&registerid="+registerid+"&folio="+folio,true);
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
		    jQuery('#reportInterface').css('display', 'none');
		    jQuery('#editSurfaceBar').css('display', 'none');
		    jQuery('#taskBar').css('display', 'block');
				jQuery('#editTaskBar').css('display', 'none');
				var onmouseover = "", onmouseout = "";
				document.getElementById('viewport').setAttribute('onmouseover', onmouseover);
			  document.getElementById('viewport').setAttribute('onmouseout', onmouseout);
        
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
        if(type == 'privat')
        	{
        	// define privat annotation configuration - functions/ buttons
		      var index = 0;
		      var parentID = "privatfields"+tagid;
		      var all = document.getElementById(parentID).childNodes;
		      for(x=0;x<all.length;x++)
		         {
		         if(all[x].nodeType == 1)
		            index++;
		         }
		      for(i=1;i<=index;i++)
        		 {
        		 var fieldID = 'directannofield'+tagid+'-'+i;
        		 if(document.getElementById(fieldID) != null)
        				{
		        		 jQuery('#'+fieldID).css('border-color','blue');
		        		 document.getElementById(fieldID).setAttribute('onmouseover', '');
		        	   document.getElementById(fieldID).setAttribute('onmouseout', '');
		        	  }
        		 }
        	var publicationStatus = xmlDoc.getElementsByTagName('publication')[0].childNodes[0].nodeValue;
        	jQuery('#contributor-div').css('display', 'none');
        	var publishstring = "askToPublish('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+lang+"', '"+registerid+"', '"+folio+"')";
        	var deletestring = "deleteAnno('"+id+"', '"+user+"', '"+lang+"', '"+registerid+"', '"+folio+"')";
        	var editstring = "prepareEditAnno('"+id+"', '"+user+"', 'privat', '"+role+"', '"+lang+"', '"+registerid+"', '"+folio+"')";
        	var editSurfacestring = "prepareEditSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', 'privat', '"+registerid+"', '"+folio+"', '"+lang+"')";
        	var addstring = "prepareAddSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', 'privat', '"+registerid+"', '"+folio+"', '"+lang+"')";
        	document.getElementById("publishButton").setAttribute('ONCLICK', publishstring);
        	document.getElementById("editButton").setAttribute('ONCLICK', editstring);
        	document.getElementById("editSurfaceButton").setAttribute('ONCLICK', editSurfacestring);
        	document.getElementById("deleteButton").setAttribute('ONCLICK', deletestring);
        	document.getElementById("addButton").setAttribute('ONCLICK', addstring);
        	if(role == 'moderator')
        		{
        		// moderator functions
        		jQuery('#reportButton').css('display', 'none');
        		jQuery('#publishButton').css('display', 'inline');
        		jQuery('#editButton').css('display', 'inline');
        		jQuery('#editSurfaceButton').css('display', 'inline');
        		jQuery('#addButton').css('display', 'inline');
        		jQuery('#deleteButton').css('display', 'inline');
        		jQuery('#taskBar').css('left', '75px');
        		}
        	else
        		{
        		// 'normal'- user functions - check publication status and define taskBar
        		if(publicationStatus != "request")
        			{
	        		jQuery('#reportButton').css('display', 'none');
	        		jQuery('#publishButton').css('display', 'inline');
	        		jQuery('#editButton').css('display', 'inline');
	        		jQuery('#editSurfaceButton').css('display', 'inline');
	        		jQuery('#addButton').css('display', 'inline');
	        		jQuery('#deleteButton').css('display', 'inline');
	        		jQuery('#taskBar').css('left', '75px');
	        		}
	        	else
	        		{
	        		// status 'wait for release' does not allow tasks on annotations
	        		jQuery('#taskBar').css('display', 'none');
	        		jQuery('#wfR').css('display', 'block');
	        		}
        		}
        	}
        else
        	{
        	// define public annotation configuration - functions/ buttons/ contributor
        	var index = 0;
		      var parentID = "publicfields"+tagid;
		      var all = document.getElementById(parentID).childNodes;
		      for(x=0;x<all.length;x++)
		         {
		         if(all[x].nodeType == 1)
		            index++;
		         }
		      for(i=1;i<=index;i++)
        		 {
        		 var fieldID = 'pubannofield'+tagid+'-'+i;
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
        	var deletestring = "deletePublicAnno('"+id+"', '"+lang+"', '"+registerid+"', '"+folio+"')";
        	var editstring = "prepareEditAnno('"+id+"', '"+user+"', 'public', '"+role+"', '"+lang+"', '"+registerid+"', '"+folio+"')";
        	var editSurfacestring = "prepareEditSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', 'public', '"+registerid+"', '"+folio+"', '"+lang+"')";
        	var reportstring = "prepareReport('"+id+"', '"+user+"', '"+lang+"', '"+registerid+"', '"+folio+"')";
        	var addstring = "prepareAddSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', 'public', '"+registerid+"', '"+folio+"', '"+lang+"')";
        	document.getElementById("reportButton").setAttribute('ONCLICK', reportstring);
        	document.getElementById("editButton").setAttribute('ONCLICK', editstring);
        	document.getElementById("editSurfaceButton").setAttribute('ONCLICK', editSurfacestring);
        	document.getElementById("deleteButton").setAttribute('ONCLICK', deletestring);
        	document.getElementById("addButton").setAttribute('ONCLICK', addstring);
        	if(role == 'moderator')
        		{
        		jQuery('#publishButton').css('display', 'none');
        		jQuery('#reportButton').css('display', 'none');
        		jQuery('#editButton').css('display', 'inline');
        		jQuery('#editSurfaceButton').css('display', 'inline');
        		jQuery('#addButton').css('display', 'inline');
        		jQuery('#deleteButton').css('display', 'inline');
        		jQuery('#taskBar').css('left', '85px');
        		}
        	else
        		{
        		jQuery('#reportButton').css('display', 'inline');
        		jQuery('#publishButton').css('display', 'none');
        		jQuery('#editButton').css('display', 'none');
        		jQuery('#editSurfaceButton').css('display', 'none');
        		jQuery('#deleteButton').css('display', 'none');
        		jQuery('#addButton').css('display', 'none');
        		jQuery('#taskBar').css('left', '120px');
        		}
        	}
        error = 0;
        }
    else
       {
       error++;
       if(error < 2)
          loadInfoTool(id, user, tagid, role, type, registerid, folio, lang);
       else
          {
          loadFadeIn();
          document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
          window.setTimeout(loadFadeOut,10000);
          error = 0;
          }   
       }
    }
  }
  xmlhttp.send();
};

// *!* ################ annotation- functions in Image- Viewport ################ *!*
// prepare to create an annotation on the image 
function prepareAnno(lang){
    // first check the coordinates
    if(checkCoords(lang))
    {
    // destroy the Jcrop function
    api.destroy();
    api = null;
    
    // reset input forms of edit interface
    jQuery('#transcription').val('');
    jQuery('#keyword').val('');
    
    // reset all annotation fields
    resetAnnoFields();
    
    // show the edit interface to insert data
    jQuery('#tooltip').css('display', 'block');
		jQuery('#showInterface').css('display', 'none');
		jQuery('#editInterface').css('display', 'block');
		
    // get the coordinates of new area
    var left = parseInt(document.getElementById('x1').value);
    var top = parseInt(document.getElementById('y1').value);
    var topinput = parseInt(document.getElementById('y1').value)+parseInt(document.getElementById('h').value)+5;
    var width = parseInt(document.getElementById('w').value);
    var height = parseInt(document.getElementById('h').value);
    // define position of dummy area und tooltip
    jQuery('#directselected').css('display', 'block');
    jQuery('#directselected').css('left', left);
    jQuery('#directselected').css('top', top);
    jQuery('#directselected').css('width', width);
    jQuery('#directselected').css('height', height);
    }
};

// prepare to edit surface of an annotation
function prepareEditSurface(id, user, tagid, role, type, registerid, folio, lang){
// hide edit Taskbar and show surface Taskbar
jQuery('#taskBar').css('display', 'none');
jQuery('#editSurfaceBar').css('display', 'block');
jQuery('#editSurfaceBar').css('left', '100px');
var back = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
var moveSurface = "prepareMoveSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
var deleteSurface = "prepareDeleteSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
document.getElementById("returnButton").setAttribute('ONCLICK', back);
document.getElementById("prepareEditSurface").setAttribute('ONCLICK', moveSurface);
document.getElementById("deleteSurface").setAttribute('ONCLICK', deleteSurface);
};

// reset onlick function
function resetOnClick(id, user, tagid, role, type, registerid, folio, lang){
// define annotation surfaces - onmouseover/onmouseout
if(type == "privat")
	{
	var parentID = "privatfields"+tagid;
	}
else
	{
	var parentID = "publicfields"+tagid;
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
       if(type == "privat")
       	var field = "directannofield"+tagid+"-"+p;
       else
       	var field = "pubannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
        	{
        	 onmouseover = "";
		       onmouseout = "";
		       onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
					 document.getElementById(field).setAttribute('onmouseover', onmouseover);
					 document.getElementById(field).setAttribute('onmouseout', onmouseout);
					 document.getElementById(field).setAttribute('onClick', onclick);
					}
       }
	 }
};

// prepare to define a new surface area
function prepareMoveSurface(id, user, tagid, role, type, registerid, folio, lang){
// define annotation surfaces - onmouseover/onmouseout
if(type == "privat")
	{
	var parentID = "privatfields"+tagid;
	}
else
	{
	var parentID = "publicfields"+tagid;
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
       if(type == "privat")
       	var field = "directannofield"+tagid+"-"+p;
       else
       	var field = "pubannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
         {
	       onmouseover = "jQuery('#"+field+"').css('border-color','red');";
	       onmouseout = "jQuery('#"+field+"').css('border-color','blue');";
	       onclick = "moveSurface('"+id+"', '"+user+"', '"+tagid+"', '"+field+"','"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
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
var cancelString = "cancelEditSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"');";
document.getElementById("cancelEdit").setAttribute('ONCLICK', cancelString);
};

// move surface area
function moveSurface(id, user, tagid, field, role, type, registerid, folio, lang){
// save x and y values to indentify old surface object
var multifactor = getImgSize(document.getElementById('img').src);
// hide old surface
jQuery('#'+field).css('display', 'none');
// save function on button
var saveString = "saveMove('"+id+"', '"+user+"', '"+tagid+"', '"+field+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
document.getElementById("addSurface").setAttribute('ONCLICK', saveString);
var saveString = "saveMove('"+id+"', '"+user+"', '"+tagid+"', '"+field+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
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
		 api = jQuery.Jcrop('#img',{ 
		    bgColor: 'red', 
		    setSelect: [ oldX, oldY, oldX2, oldY2 ],
		    onChange: saveCoords,
				onSelect: saveCoords
		 	});
		 }
};

// save the new position coordinates of annotation surface
function saveMove(id, user, tagid, field, role, type, registerid, folio, lang){
	if(checkCoords(lang))
		{
		// get image informations - coordinates, src- code
		var surfaceID = document.getElementById(field).getAttribute('lang');
	  var multifactor = getImgSize(document.getElementById('img').src);
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
    loadFadeIn();
    xmlhttp.open("POST","../service/edit-surface?id="+id+"&user="+user+"&type="+type,true);
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
              resetOnClick(id, user, tagid, role, type, registerid, folio, lang);
              
              // show informations to user
              jQuery('#loadgif').css('display', 'none');
              document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
              window.setTimeout(loadFadeOut,4000);
                    
              // load data into editor
              loadInfoTool(id, user, tagid, role, type, registerid, folio, lang);
              
							// show taskBar and hide editTaskBar
							jQuery('#taskBar').css('display', 'block');
							jQuery('#editTaskBar').css('display', 'none');
							jQuery('#editSurfaceBar').css('display', 'none');
							
							// destroy the cropping function
						  api.destroy();
						  api = null;
              }
				  else
				      {
				      jQuery('#loadgif').css('display', 'none');
				      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
				      window.setTimeout(loadFadeOut,10000);
				      }    
          error = 0;
          }
       else
          {
          error++;
          if(error < 20)
            saveMove(id, user, tagid, field, role, type, registerid, folio, lang);
          else
            {
            jQuery('#loadgif').css('display', 'none');
            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
            window.setTimeout(loadFadeOut,10000);
            error = 0;
            }    
          }
       }
    };
    xmlhttp.send(parameters);
	}
};

// cancel to edit a surface area
function cancelEditSurface(id, user, tagid, role, type, registerid, folio, lang){
// show taskBar and hide editTaskBar
jQuery('#taskBar').css('display', 'block');
jQuery('#editTaskBar').css('display', 'none');
jQuery('#editSurfaceBar').css('display', 'none');
jQuery('#addSurface').css('display', 'block');
// define annotation surfaces - onmouseover/onmouseout
if(type == "privat")
	{
	var parentID = "privatfields"+tagid;
	}
else
	{
	var parentID = "publicfields"+tagid;
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
       if(type == "privat")
       	var field = "directannofield"+tagid+"-"+p;
       else
       	var field = "pubannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
         {
	       var  onmouseover = "", onmouseout = "", onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
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
function prepareDeleteSurface(id, user, tagid, role, type, registerid, folio, lang){
// define annotation surfaces - onmouseover/onmouseout
if(type == "privat")
	{
	var parentID = "privatfields"+tagid;
	}
else
	{
	var parentID = "publicfields"+tagid;
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
       if(type == "privat")
       	var field = "directannofield"+tagid+"-"+p;
       else
       	var field = "pubannofield"+tagid+"-"+p;
       if(document.getElementById(field) != null)
         {
	       var onmouseover = "jQuery('#"+field+"').css('border-color','red');";
	       var onmouseout = "jQuery('#"+field+"').css('border-color','blue');";
	       var onclick = "deleteSurface('"+id+"', '"+user+"', '"+tagid+"', '"+field+"','"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
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
var cancelString = "cancelEditSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"');";
document.getElementById("cancelEdit").setAttribute('ONCLICK', cancelString);
};

// delete a surface area
function deleteSurface(id, user, tagid, field, role, type, registerid, folio, lang){
// count fields
if(type == "privat")
	{
	var parentID = "privatfields"+tagid;
	}
else
	{
	var parentID = "publicfields"+tagid;
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
	if(type == "privat")
		deleteAnno(id, user, lang, registerid, folio);
	else
		deletePublicAnno(id, lang, registerid, folio);
	}
else
	{
	// ask the user to confirm this step
  if(confirm(geti18nText(lang, 'delete-surface-question')))
    { 
		// ID to indentify old surface object
		var surfaceID = document.getElementById(field).getAttribute('lang');
		var multifactor = getImgSize(document.getElementById('img').src);
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
		loadFadeIn();
		xmlhttp.open("POST","../service/delete-surface?id="+id+"&user="+user+"&type="+type,true);
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
		           loadFadeIn();
		           document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
		           window.setTimeout(loadFadeOut,4000);
			         }
					 else
							{
							jQuery('#loadgif').css('display', 'none');
							document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
							window.setTimeout(loadFadeOut,10000);
							}    
				   error = 0;
				   }
				else
				   {
				   error++;
				   if(error < 20)
				      deleteSurface(id, user, tagid, field, role, type, registerid, folio, lang)
				   else
				      {
				      jQuery('#loadgif').css('display', 'none');
				      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
				      window.setTimeout(loadFadeOut,10000);
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
resetOnClick(id, user, tagid, role, type, registerid, folio, lang);
// load data into editor
loadInfoTool(id, user, tagid, role, type, registerid, folio, lang);
};

// prepare to add a new surface to an annotation
function prepareAddSurface(id, user, tagid, role, type, registerid, folio, lang){
	// hide taskBar and show editTaskBar
	jQuery('#taskBar').css('display', 'none');
	jQuery('#editTaskBar').css('display', 'block');
	jQuery('#editTaskBar').css('left', '60px');
	
	// save and cancel function on buttons
	var saveString = "addSurface('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
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
	
	// create a new api object
	if(api==null)
	   {
	   // andere function - button im Taskbar
		 api = jQuery.Jcrop('#img',{ 
		    bgColor: 'red', 
		    onChange: saveCoords,
				onSelect: saveCoords
		 	});
		 }
};

// add a new surface to an annotation
function addSurface(id, user, tagid, role, type, registerid, folio, lang){
	if(checkCoords(lang))
		{
		// get image informations - coordinates, src- code
	  var multifactor = getImgSize(document.getElementById('img').src);
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
    loadFadeIn();
    xmlhttp.open("POST","../service/add-surface?id="+id+"&user="+user+"&type="+type,true);
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
		          if(type == "privat")
								{
								var parentID = "privatfields"+tagid;
								}
							else
								{
								var parentID = "publicfields"+tagid;
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
              var onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', '"+type+"', '"+registerid+"', '"+folio+"', '"+lang+"')";
                    
              // define style and mouse actions
              if(type == "privat")
			       		var fieldid = "directannofield"+tagid+"-"+fieldIdNumber;
			       	else
			       		var fieldid = "pubannofield"+tagid+"-"+fieldIdNumber;
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
              window.setTimeout(loadFadeOut,4000);
                    
              // load data into editor
              if(type == 'privat')
                loadInfoTool(id, user, tagid, role, 'privat', registerid, folio, lang);
              else
                loadInfoTool(id, user, tagid, role, 'public', registerid, folio, lang);
              // hide taskBar and show editTaskBar
              jQuery('#'+fieldid).css('display', 'block');
							jQuery('#taskBar').css('display', 'block');
							jQuery('#editTaskBar').css('display', 'none');
							// destroy the cropping function
						  api.destroy();
						  api = null;
              }
				  else
				      {
				      jQuery('#loadgif').css('display', 'none');
				      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
				      window.setTimeout(loadFadeOut,10000);
				      }    
          error = 0;
          }
       else
          {
          error++;
          if(error < 20)
            addSurface(id, user, tagid, role, type, registerid, folio, lang);
          else
            {
            jQuery('#loadgif').css('display', 'none');
            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
            window.setTimeout(loadFadeOut,10000);
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

// cancel process to create an annotation 
function cancelAnno(user, role, lang, registerid, folio){
		// reset buttons and tooltip
    jQuery('.hiddenButton').css('display', 'none');
    jQuery('#keyword').val('');
    jQuery('#transcription').val('');
    jQuery('#viewmode').css('display', 'none');
    jQuery('#selectmode').css('display', 'inline');
    jQuery('#tooltip').css('top', '200');
    jQuery('#tooltip').css('left', '200');
    jQuery('#directselected').css('display', 'none');
    
    // reset all annotation fields
    closeInfoField();
    
    // reset save button
    var storestring = "storeAnno('"+user+"', '"+role+"', '"+lang+"', '"+registerid+"', '"+folio+"');"
    document.getElementById('saveanno').removeAttribute('ONCLICK');
    document.getElementById('saveanno').setAttribute('ONCLICK', storestring);
}

// store the user's annotation in his userfile
function storeAnno(user, role, lang, registerid, folio){
        if(checkCoords(lang))
        {
        // get image informations - coordinates, src- code
        var url = document.getElementById("img").getAttribute("src");
        var multifactor = getImgSize(document.getElementById('img').src);
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
        // get annotationtext        
        var transcription = jQuery('#transcription').val();
        var category =  jQuery('#category').val();
        var keyword =  jQuery('#keyword').val();
        // check for the user's input
        if (transcription == '' || category == '' || keyword == '')
            {
            alert(geti18nText(lang, 'please-insert-metadata'));
            }
        else
        {
        var parameters = "url="+url+"?!x1="+nx1+"?!x2="+nx2+"?!y1="+ny1+"?!y2="+ny2+"?!size="+size+"?!category="+category+"?!transcription="+transcription+"?!keyword="+keyword+"?!registerid="+registerid+"?!folio="+folio+"?!";
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
        loadFadeIn();      
        xmlhttp.open("POST","../service/annotate?user="+user,true);
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                 		// get id from ajax response
                    var id = xmlhttp.responseText;
                    
                   	// define ID because of existing elements
                    var index = 0;
                    var all = document.getElementById("privatAnnos").childNodes;
                    for(x=0;x<all.length;x++)
                        {
                        if(all[x].nodeType == 1)
                             index++;
                        }
                    var tagid = index+1;
                    
                    // functions
                    var onclick = "loadInfoTool('"+id+"', '"+user+"', '"+tagid+"', '"+role+"', 'privat', '"+registerid+"', '"+folio+"', '"+lang+"')";
                    var onmouseover = "jQuery('#directannofield"+tagid+"-1').css('border-color','blue');";
                    var onmouseout = "jQuery('#directannofield"+tagid+"-1').css('border-color','#EF6A2F');";
                    
                    // define style and mouse actions
                    var fieldid = "directannofield"+tagid+"-1"; 
                    var fieldstyle = "left:"+x1+"px;top:"+y1+"px;height:"+x2+"px;width:"+y2+"px;";
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
                    
                    // create parent div
                    var parentid = "privatfields"+tagid; 
                    var fielddiv = document.createElement("div");
                    fielddiv.setAttribute('ID', parentid);
                    fielddiv.appendChild(annofield);
                    
                    // create main div
                    var maindiv = document.createElement("div");
                    maindiv.setAttribute('ID', id);
                    maindiv.setAttribute('NAME', 'AnnoElement');
                    maindiv.appendChild(fielddiv);
                    
                    // add new tags to existing elements
                    document.getElementById("privatAnnos").appendChild(maindiv);
                    jQuery('#loadgif').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                    window.setTimeout(loadFadeOut,4000);
                    
                    // load data into editor
                    loadInfoTool(id, user, tagid, role, 'privat', registerid, folio, lang);
                    
                    // set editor to viewmode
                    jQuery('#directselected').css('display', 'none');
                    jQuery('#selectmode').css('display', 'block');
                    jQuery('#'+fieldid).css('display', 'block');
                    jQuery('#viewmode').css('display', 'none');
                    jQuery('.hiddenButton').css('display', 'none');
                    jQuery('#transcription').val('');
                    jQuery('#keyword').val('');
                    error = 0;
                  }
             else
                  {
                  error++;
                  if(error < 20)
                      storeAnno(user, role, lang, registerid, folio);
                  else
                      {
                      jQuery('#loadgif').css('display', 'none');
                      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                      window.setTimeout(loadFadeOut,10000);
                      error = 0;
                      }    
                 }
                }
         };
        xmlhttp.send(parameters);
        }
        }
    }

// prepare to edit an annotationtext
function prepareEditAnno(id, user, type, role, lang, registerid, folio){
    //define save string
    var updatestring = "updateAnno('"+id+"', '"+user+"', '"+type+"','"+role+"', '"+lang+"', '"+registerid+"', '"+folio+"');";
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
};

// edit an annotationtext in the DB
function updateAnno(id, user, type, role, lang, registerid, folio){
        var transcription = jQuery('#transcription').val();
        var keyword = jQuery('#keyword').val();
        var category = jQuery('#category').val();
        var parameters = "?!category="+category+"?!keyword="+keyword+"?!transcription="+transcription+"?!registerid="+registerid+"?!folio="+folio+"?!";
        // check for the user's input
        if (transcription == '' || category == '' || keyword == '')
            {
            alert(geti18nText(lang, 'please-insert-an-annotation'));
            }
        else
        {
        jQuery('#loadgif').css('display', 'block');
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'updating-data'); 
        jQuery("#loading").animate({
        "marginTop": 51
        }, 500, function() {
        // Animation complete.
  
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
        if(type == 'privat')            
            xmlhttp.open("POST","../service/edit-private-annotation?user="+user+"&id="+id,false);
        else
            xmlhttp.open("POST","../service/edit-public-annotation?id="+id,false);
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
                 var savestring = "storeAnno('"+user+"','"+role+"','"+lang+"','"+registerid+"','"+folio+"');";
                 document.getElementById('saveanno').removeAttribute('ONCLICK');
                 document.getElementById('saveanno').setAttribute('ONCLICK', savestring);
                 jQuery('#keyword').val('');
                 jQuery('#transcription').val('');
                 
                 // update the text of the annotationfield
                 document.getElementById("category-content").innerHTML = category;
				         document.getElementById("keyword-content").innerHTML = keyword;
				         document.getElementById("transcription-content").innerHTML = transcription;
                 
                 document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                 window.setTimeout(loadFadeOut,4000);
                 // add the toolbar to the annotation
                 error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        updateAnno(id, user, type, role, lang, registerid, folio);
                    else
                        {
                        jQuery('#loadgif').css('display', 'none');
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        } 
                 }
              }
        };
        xmlhttp.send(parameters);
        });
        }
        
};

// send a request to the moderator to publish the annotation
function askToPublish(id, user, tagid, role, lang, registerid, folio){
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'sending-request');
        jQuery('#loadgif').css('display', 'block');
        jQuery('#loadtext').css('display', 'block');
        jQuery("#loading").animate({
        "marginTop": 51
        }, 500, function() {
        // send request to service
        if(role == 'user')
                {
                xmlhttp.open("GET","../service/publish-annotation?type=ask&id="+id+"&user="+user+"&registerid="+registerid+"&folio="+folio,true);
                }
        else
                {
                xmlhttp.open("GET","../service/publish-annotation?type=directPub&id="+id+"&user="+user+"&registerid="+registerid+"&folio="+folio,true);
                }
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                 jQuery('#loadgif').css('display', 'none');
                 if(role == 'user')
                    {                 
                    // request has been succesfull transmitted to moderator
                    jQuery('#loadgif').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'request-sent-to-moderator');
                    window.setTimeout(loadFadeOut,4000);
                    
                    // status 'wait for release' does not allow tasks on annotations
				        		jQuery('#taskBar').css('display', 'none');
				        		jQuery('#wfR').css('display', 'block');
                    }
                 else
                    {
                    // annotation has been released
                    jQuery('#loadgif').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'the-annotation-has-been-released');
                    window.setTimeout(loadFadeOut,4000);
                    // reload page
                    window.location.reload();
                    } 
                    error = 0;
                  }
             else
                  {
                  error++;
                  if(error < 20)
                      askToPublish(id, user, tagid, role, lang, registerid, folio);
                  else
                      {
                      jQuery('#loadgif').css('display', 'none');
                      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                      window.setTimeout(loadFadeOut,10000);
                      error = 0;
                      }                    
                  }
            }
        };
        xmlhttp.send();
        });
    };

// reprint annotations after zooming   
function reprintAnnos(size, oldsize){
    // calculate the zooming factor
    var multifactor = size/oldsize;
    // go through all privat annotations
    var all = document.getElementById("privatAnnos").childNodes;
    var number = 0;
    for(x=0;x<all.length;x++)
        {
        if(all[x].nodeType == 1)
             number++;
        }
    // calculate the new coordinates
    for(i=1;i<=number;i++)
        {
        var parentID = "privatfields"+i;
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
				      var field = "directannofield"+i+"-"+u;
				      if(document.getElementById(field) != null)
        				{
				        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)*multifactor)+"px";
				        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)*multifactor)+"px";
				        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)*multifactor)+"px";        
				        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)*multifactor)+"px";
				        }
			       }
		       }
        }
    // go through all public annotations
    var allpub = document.getElementById("publicAnnos").childNodes;
    var number = 0;
    for(x=0;x<allpub.length;x++)
        {
        if(allpub[x].nodeType == 1)
             number++;
        }
    // calculate the new coordinates
    for(i=1;i<=number;i++)
        {
        var parentID = "publicfields"+i;
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
				      var field = "pubannofield"+i+"-"+u;
				      if(document.getElementById(field) != null)
        				{
				        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)*multifactor)+"px";
				        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)*multifactor)+"px";
				        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)*multifactor)+"px";        
				        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)*multifactor)+"px";
				        }
			       }
		       }
        }
    document.getElementById("directselected").style.top = Math.round(parseInt(document.getElementById("directselected").style.top)*multifactor)+"px";
    document.getElementById("directselected").style.left = Math.round(parseInt(document.getElementById("directselected").style.left)*multifactor)+"px";
    document.getElementById("directselected").style.width = Math.round(parseInt(document.getElementById("directselected").style.width)*multifactor)+"px";
    document.getElementById("directselected").style.height = Math.round(parseInt(document.getElementById("directselected").style.height)*multifactor)+"px";
 };

// delete an annotation
function deleteAnno(id, user, lang, registerid, folio){
    // ask the user to confirm this step
    if(confirm(geti18nText(lang, 'delete-annotation-question')))
    { 
        // send a request to the crop script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }      
        xmlhttp.open("GET","../service/delete-private-annotation?id="+id+"&user="+user+"&registerid="+registerid+"&folio="+folio,true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                    var response = xmlhttp.responseText;
                    // delete annotation on the screen
                    if (response == "delete")
                        {   
                        		document.getElementById(id).style.display = "none";
                        		
                            // show message
                            loadFadeIn();
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                            window.setTimeout(loadFadeOut,4000);
                            
                            // hide and reset tooltip
                            closeInfoField();
												    jQuery('#tooltip').css('top', '200');
												    jQuery('#tooltip').css('left', '200');
                        }
                    else 
                        {
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        }
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        deleteAnno(id, user, lang, registerid, folio);
                    else
                        {
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        }   
                 }
            }
        }
        xmlhttp.send();
    }
};

// delete public annotation
function deletePublicAnno(id, lang, registerid, folio) {
    // ask the user to confirm this step
    if(confirm(geti18nText(lang, 'delete-annotation-question')))
    { 
        // send a request to the crop script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","../service/delete-public-annotation?id="+id+"&registerid="+registerid+"&folio="+folio,true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             
             if (xmlhttp.status==200)
                 {
                    var response = xmlhttp.responseText;
                    // delete annotation on the screen
                    if (response == "delete")
                        {  
                        var delID = "pub"+id;
                        document.getElementById(delID).style.display = "none";
                        error = 0;
                        
                        // hide and reset tooltip
                        closeInfoField();
												jQuery('#tooltip').css('top', '200');
												jQuery('#tooltip').css('left', '200');
												
												// show message
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                        window.setTimeout(loadFadeOut,4000);
                        }
                   }
             else
                 {
                    error++;
                    if(error < 20)
                        deletePublicAnno(id, lang, registerid, folio);
                    else
                        {
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        }                         
                   }
                 }
        }
        xmlhttp.send();
     }
};

// critizise an annotation and send a report to the moderator - open the a comment field an prepare to send a request
function prepareReport(id, user, lang, registerid, folio){
//reset reportfield
jQuery('#comment').val('');
// set report function
var reportstring = "sendReport('"+id+"', '"+user+"', '"+lang+"', '"+registerid+"', '"+folio+"');";
jQuery('#showInterface').css('display', 'none');
jQuery('#reportInterface').css('display', 'block');
document.getElementById('sendReport').setAttribute('ONCLICK', reportstring);        
}

// cancel report process
function cancelReport(){
		// hide divs
    jQuery('#showInterface').css('display', 'block');
    jQuery('#reportInterface').css('display', 'none');
    jQuery('#comment').val('');
}

// send the report request to the moderator
function sendReport(id, user, lang, registerid, folio){
// get report text        
var critic = jQuery('#comment').val();
// check for the user's input
if (critic == '')
   {
   alert(geti18nText(lang, 'please-insert-a-comment'));
   }
else
   {
   var xmlhttp;
   if (window.XMLHttpRequest)
      {// code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp=new XMLHttpRequest();
      }
   else
      {// code for IE6, IE5
      xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
		// show user information
		document.getElementById("loadtext").innerHTML = geti18nText(lang, 'sending-request');
		loadFadeIn();
		jQuery('#loadgif').css('display', 'block');
		jQuery('#loadtext').css('display', 'block');
		// send request to service
		xmlhttp.open("POST","../service/report-annotation?id="+id+"&user="+user+"&registerid="+registerid+"&folio="+folio, true);
		xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
		xmlhttp.onreadystatechange=function(){
		if (xmlhttp.readyState==4)
		   {
		   if (xmlhttp.status==200)
		      {
		      jQuery('#showInterface').css('display', 'block');
		    	jQuery('#reportInterface').css('display', 'none');
		      jQuery('#comment').val('');
		      jQuery('#loadgif').css('display', 'none');
		      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'sending-request');
		      window.setTimeout(loadFadeOut,4000);
		      error = 0;
		      }
		   else
		      {
		      error++;
		      if(error < 20)
		        sendReport(id, user, lang, registerid, folio);
		      else
		        {
		        jQuery('#loadgif').css('display', 'none');
		        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
		        window.setTimeout(loadFadeOut,10000);
		        error = 0;
		        }
		      }
		   }
		};
		xmlhttp.send(critic);
	}
};
