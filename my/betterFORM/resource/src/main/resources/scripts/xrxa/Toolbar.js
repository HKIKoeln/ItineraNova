/*
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see http://www.gnu.org/licenses.
 */
//author: daniel.ebner@uni-koeln.de

dojo.provide('xrxa.Toolbar');


dojo.require("xrxa.util");

//dojo.require("xrxa._editor.EditorText");
dojo.require("xrxa.Select");
dojo.require('dijit._Widget');
dojo.require('xrxa.Option');
dojo.require('xrxa.TextInsertion');
dojo.require("xrxa.InsertAnnotationItem");
dojo.require("xrxa.InsertTextButton");


dojo.require("dijit.MenuBar");
dojo.require("dijit.MenuBarItem");
dojo.require("dijit.PopupMenuBarItem");
dojo.require("dijit.Menu");
dojo.require("dijit.MenuItem");
dojo.require("dijit.PopupMenuItem");
dojo.require("dijit.Toolbar");
dojo.require("dijit.form.Button");

dojo.require("dojox.xml.parser");

dojo.declare("xrxa.Toolbar", dijit._Widget,
{
    constructor : function(params){
    	
    	
	 
	this.id = params.id;
    this.name = params.name; 
	this.annotationControl = params.annotationControl;
	
	
	
    
  },
	
  postCreate : function()
  {	
	  
  
	  this.domNode =  dojo.create('div', {id: this.id, class: 'xrxaAnnotationHeader'});	
	
	  this.connect(this.domNode, "onmouseenter", "onMouseEnter"); 
	  
	  this.addControls();

	  
	  //Only Update on Click ??
	  this.update();
	  

  },
  

  
  update: function(){

	  this.updateContext();
	  //this.updateSelect();
	  this.updateMenu();
	
  },
  
  
  //TODO: Move to Selection
  updateContext: function(){ 
	  	 
	
	  if(this.annotationControl.selection.content){
		  this.context = this.annotationControl.selection.content.element.getContext();
		  }
	  
	  else {
		  //should never be called
		  console.log('Toolbar.updateContext, unexpected behaviour: no responsible content-object for the selection ', this.annotationControl.selection);
		  this.context= this.annotationControl.getContext();	  
	  }
		  
	  selectedAnnotations = this.annotationControl.selection.getSelectedAnnotations();	  
	  if(selectedAnnotations){	  
		  
		  this.context = this.context + '[';
		  
		  for(var i=0; i< selectedAnnotations.length; i++){
			  annotation = selectedAnnotations[i];
	
			  if(annotation.declaredClass=='xrxa.Annotation'){
				  //console.log('Element: ',element.tagname);
				  this.context = this.context + annotation.getContext();
				  this.context = this.context + ' ';
				  
			  } 
		  }
		  
		  this.context = this.context + ']';	
	  }
  },
  

  
  addControls: function(){

	this.addMenu();
	this.insertText = new xrxa.InsertTextButton({annotationControl: this.annotationControl});
	  
	dojo.place(this.insertText.domNode, this.domNode);
	
	//UNCOMMENT TO USE AGAIN
	//this.addTextInsertion();
	  
  },
  
  addContextDiv: function(){
	   this.contextDiv = dojo.create('div');
	   dojo.place(this.contextDiv, this.domNode, 'first');
	   
  },
  
  
  addSelect: function(){
	    this.select = new xrxa.Select({name:'name', id:this.id+'-select'});
	    //UNSELECT TO INSERT AGAIN
	    //dojo.place(this.select.domNode, this.domNode, 'first');

  },
  
  addMenu : function(){
	  
	  //MenuBar horizontal
	  this.menuBar = new dijit.MenuBar({});
	  dojo.addClass(this.menuBar.domNode, 'xrxaMenu');
	  dojo.place(this.menuBar.domNode, this.domNode, 'last');
      this.menuBar.startup();
      
	  

      

  },
  
  addToolbar : function(){
	  this.toolbar = new dijit.Toolbar({});
	  dojo.addClass(this.toolbar.domNode, 'xrxaToolbar');
	  
	  this.insertText = new xrxa.InsertTextButton({annotationControl: this.annotationControl});
	  
	  this.toolbar.addChild(this.insertText);
	  
	  //this.domNode.addChild(this.insertText);
	  
	  dojo.place(this.toolbar.domNode, this.domNode);
  },
  
  updateMenu : function(){
	  var defualtSubMenu = this.defualtSubMenu;
	  var selection = this.annotationControl.selection;
	  var parser = dojox.xml.parser
	  var id = this.id;
	  var menuBar = this.menuBar;  

	  
	    
		dojo.xhrGet({
			url: this.annotationControl.services + "?service=get-menu&context=" + this.context + "&xsdloc=" + this.annotationControl.xsdloc,
			

	        load: function(result){
                    menuBar.domNode.innerHTML='';
	        	 	//dojo.empty(defualtSubMenu.domNode);
	        	
	        		//clean Menu bar
                   
                    var xresult = parser.parse(result);                   
                    
                    var subMenus = xresult.documentElement.childNodes;
                    
                    for(var i=0; i< subMenus.length; i++){
                    	if(subMenus[i].nodeName=="xrxe:sub-menu"){
                    		var subMenuElement = subMenus[i];
                    		var menuItem = subMenuElement.firstElementChild;   
                    		var menuItemLabel = menuItem.firstChild.data
                    		//console.log('********************************menuItem', menuItemLabel);
                    		
                    		var subMenu = new dijit.Menu({});
                    		var popupMenuBarItem = new dijit.PopupMenuBarItem({
        	        	          label: menuItemLabel,
        	        	          popup: subMenu
        	        	      });        	        		
        	        		menuBar.addChild(popupMenuBarItem);
                    		
                    		for(var j=0; j< subMenuElement.childNodes.length; j++){

                                if(subMenuElement.childNodes[j].nodeName=="xrxe:option"){
                    				var option = subMenuElement.childNodes[j];
                    				insertAnnotationItem = new xrxa.InsertAnnotationItem({option: option, selection: selection, });
                    				dojo.place(insertAnnotationItem.domNode, subMenu.domNode, 'last');
                    			}
                    		}
                    	}                    	
                    }

   
                    

            		
            		
                    
                    /*for(var i=0; i< options.length; i++){
                            if(options[i].nodeName=='option'){

                                    option = new xrxa.InsertAnnotationItem({option: options[i], selection: selection, });
                                    
                                    
                                    //If a menu item is set, place at a specific menu item
                                    if(options[i].firstElementChild.nextElementSibling){
                                    	if(options[i].firstElementChild.nextElementSibling.nodeName=="xrxe:menu-item"){
                                    		

                                        	var subMenuLabel = options[i].firstElementChild.nextElementSibling.firstChild.data;
                                        	var subMenuId =  id + subMenuLabel + 'subMenu';                                        	
                                         	var subMenu = dijit.byId(subMenuId);
                                         	
                                         	console.log('sb', subMenus);
                                         	console.log('Get Submenu!!!!', options[i], subMenuId, subMenu);
                                        	
                                        	
                                        	dojo.place(option.domNode, subMenu.domNode, 'last');
                                    		
                                        }
                                    }
                                    
                                    //else place at default menu Item
                                    else{
                                    	 dojo.place(option.domNode, defualtSubMenu.domNode, 'last');
                                    
                                    }
                                   
                            }
                    }*/
	        	 	                        
	        }
		});  
		
		//this.menuBar.addChild(this.insertText);
  },
  
  
  /*addTextInsertion: function(){
	    this.textInsertion = new xrxa.TextInsertion({annotationControl: this.annotationControl});
		dojo.place(this.textInsertion.domNode, this.domNode, 'last');
  },*/
  
  onMouseEnter: function(e){
	  this.annotationControl.selection.update();
  },
  
  
 
  

 
  
  
  
  
  
});
