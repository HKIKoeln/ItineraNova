var error = 0;

function prepareEdit(number){
    var container = "#modContainer"+number;
    var select = "#modSelect"+number;
    var edit = "#edit"+number;
    var save = "#save"+number;
    $(select).css('display', 'block');
    $(container).css('display', 'none');
    $(edit).css('display', 'none');
    $(save).css('display', 'block');
};

function saveModeration(number, user){
    var select = "#modSelect"+number;
    var moderator =  jQuery(select).val();
    // send request to edit-category script
    var xmlhttp;
    if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari
           xmlhttp=new XMLHttpRequest();
        }
    else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
    xmlhttp.open("GET","./service/edit-moderator?user="+user+"&moderator="+moderator, true);
    xmlhttp.onreadystatechange=function(){
    if(xmlhttp.readyState==4)
      {
      if (xmlhttp.status==200)
          {
            var container = "#modContainer"+number;
            var text = "modText"+number;
            var select = "#modSelect"+number;
            var edit = "#edit"+number;
            var save = "#save"+number;
            document.getElementById(text).innerHTML = moderator;
            $(select).css('display', 'none');
            $(container).css('display', 'block');
            $(edit).css('display', 'block');
            $(save).css('display', 'none');
            error = 0
          }          
     else
          {
          error++;
          if(error < 20)
             saveModeration(number, user);
          else
             {
             error = 0;
             }
           }
       }
      };
     xmlhttp.send();
};

function removeCategory(categoryID){
    // send request to edit-DataProvider script
    var xmlhttp;
    if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari
           xmlhttp=new XMLHttpRequest();
        }
    else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
    xmlhttp.open("GET","./service/edit-category?type=remove-category&category="+categoryID, true);
    xmlhttp.onreadystatechange=function(){
    if(xmlhttp.readyState==4)
      {
      if (xmlhttp.status==200)
          {
            var old = document.getElementById(categoryID);
            old.parentNode.removeChild(old);
          }          
     else
          {
          error++;
          if(error < 20)
             deleteCategory(categoryID);
          else
             {
             error = 0;
             }
           }
       }
      };
     xmlhttp.send();
};