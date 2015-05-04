var error = 0;

function prepareAdding(){
    $('#input-category').css('display', 'block');
    $('#input-category').val('');
    $('#save-category').css('display', 'block');
    $('#add-category').css('display', 'none');
};

function addCategory(){
    $('#input-category').css('display', 'none');
    var input = $('#input-category').val();
    $('#save-category').css('display', 'none');
    $('#add-category').css('display', 'block');
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
    xmlhttp.open("GET","./service/edit-category?type=add-category&category="+input, true);
    xmlhttp.onreadystatechange=function(){
    if(xmlhttp.readyState==4)
      {
      if (xmlhttp.status==200)
          {
            var breadcrump = document.createElement("div");
            breadcrump.innerHTML = xmlhttp.responseText;
            document.getElementById('list').appendChild(breadcrump);
            error = 0
          }          
     else
          {
          error++;
          if(error < 20)
             addCategory();
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