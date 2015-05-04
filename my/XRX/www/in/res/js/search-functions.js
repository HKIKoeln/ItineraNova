
// on load functions
jQuery(function() {
                        loadCoordinates();
                        loadTooltip();
                });
                
// normalize coordinates of the direct annotations
function loadCoordinates(){
    // calculate the zooming factor
    var newImg = new Image();
    newImg.src = document.getElementById('toolimg1').src;
    jQuery(newImg).load(function(){
        var all = document.getElementById("result").childNodes;
        var multifactor = newImg.width/jQuery('#img1').width();
        
        var number = 0;
        for(x=0;x<all.length;x++)
            {
            if(all[x].nodeType == 1)
                 number++;
            }
          
        // calculate the new coordinates
        for(i=1;i<=number;i++)
            {
            var parentID = "resultfields"+i;
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
						      var field = "anno"+i+"-"+u;
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

// normalize coordinates of tooltips
function loadTooltip(){
    // calculate the zooming factor
    var newImg = new Image();
    newImg.src = document.getElementById('toolimg1').src;
    jQuery(newImg).load(function(){
        var number = 0;
        var all = document.getElementById("result").childNodes;
        var multifactor = newImg.width/jQuery('#toolimg1').width();
        for(x=0;x<all.length;x++)
            {
            if(all[x].nodeType == 1)
                 number++;
            }
        // calculate the new coordinates
        for(i=1;i<=number;i++)
            {
            var parentID = "resulttoolfields"+i;
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
						      var field = "annotool"+i+"-"+u;
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

// show the image tooltip
function showTooltip(e, id){
    // Calculate the position of the image tooltip
    var viewid = '#img'+id;
    var toolid = '#tool'+id;
    x = e.pageX;
    y = e.pageY;
 
    // Set the z-index of the current item,
    // make sure it's greater than the rest of thumbnail items
    // Set the position and display the image tooltip
    jQuery(viewid).css('z-index','15');
    jQuery(toolid).css({'top': y - 650,'left': x - 200,'display':'block'});
};

// hide the image tooltip
function hideTooltip(e, id){
    var viewid = '#img'+id;
    var toolid = '#tool'+id;
    // Reset the z-index and hide the image tooltip
    jQuery(viewid).css('z-index','1');
    jQuery(toolid).animate({"opacity": "hide"}, "fast");
};

// add a category to search parameters
function addCategory(buttonNumber)
{   
    // ID for new 'AND' element
    var numberOfAnd = parseInt(buttonNumber)+1;
    
    // edit clicked button to remove created elements
    var removeClick = "removeCategory('"+numberOfAnd+"', '"+buttonNumber+"');"; 
    jQuery('#add-button-'+buttonNumber).attr('onClick', removeClick);
    
    // create new select list
    var newselect = document.createElement("select");
    var name = 'category-'+numberOfAnd;
    var ID = 'select-category-'+numberOfAnd;
    newselect.setAttribute('id', ID);
    newselect.setAttribute('style', 'position:relative;left:3px;');
    newselect.setAttribute('name', name);
    
    // create options of select element
    $("#select-category-0 option").each(function()
        {
        // add $(this).val() to options
        if($(this).val() != 'all')
            {
            var option = document.createElement("option");
            option.innerHTML = $(this).val();
            newselect.appendChild(option);
            }
        });
        
    // create new button   
    var newbutton = document.createElement("input");
    var buttonID = 'add-button-'+numberOfAnd;
    var clickString = 'addCategory('+numberOfAnd+');';
    newbutton.setAttribute('type', 'button');
    newbutton.setAttribute('id', buttonID);
    newbutton.setAttribute('value', '+');
    newbutton.setAttribute('onClick', clickString);
    newbutton.setAttribute('style', 'position:relative;left:3px;');
        
    // div position has to be removed
    jQuery('#category').css({'position':'relative','right':'3px'});
    // edit clicked button to remove created elements
    var removeClick = "removeCategory('"+numberOfAnd+"', '"+buttonNumber+"');"; 
    jQuery('#add-button-'+buttonNumber).attr('onClick', removeClick);
    jQuery('#add-button-'+buttonNumber).val('&');
    // add new elements to html code
    jQuery('#add-button-'+buttonNumber).after(newbutton);
    jQuery('#add-button-'+buttonNumber).after(newselect);  
};

// remove category from search parameters
function removeCategory(nextNumber, buttonNumber)
{
var delButtonId = 'add-button-'+nextNumber;
var nextValue = $("#add-button-"+nextNumber).val();
// extract ID of followed element
var nextId = $("#add-button-"+nextNumber).attr('onClick');
var newNext = nextId.substring(16,nextId.indexOf(",")-1);
// define form of button    
if(nextValue == '&')
    var Click = "removeCategory('"+newNext+"', '"+buttonNumber+"');";
else
    var Click = 'addCategory('+buttonNumber+');';
// delete category
var delSelectId = 'select-category-'+nextNumber;
var button = document.getElementById(delButtonId);
button.parentNode.removeChild(button);
var select = document.getElementById(delSelectId);
select.parentNode.removeChild(select);
// edit button
$("#add-button-"+buttonNumber).attr('onClick', Click);
$("#add-button-"+buttonNumber).attr('value', nextValue);
};

function checkAdding(number)
{
    // only display button when 'all' is not selected
    if(jQuery('#select-category-0 option:selected').val() != 'all')
        jQuery('#and-options').css('display', 'inline');
    else
        jQuery('#and-options').css('display', 'none');
};

function changeRegister()
{
    // only display folio options when 'all' is not selected in register select
    if(jQuery('#register option:selected').val() != 'all')
        {
        jQuery('#folio').css('display', 'block');
        if (jQuery.browser.webkit)
            jQuery('#annotation-params').css('top', '157px');
        else
            jQuery('#annotation-params').css('top', '154px');
        }
    else
        {
        jQuery('#folio').css('display', 'none');
        jQuery('#annotation-params').css('top', '123px');
        jQuery('#folio-input').val('');
        }
};

