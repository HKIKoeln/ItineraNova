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

dojo.provide('xrxa.InsertTextButton');

dojo.require("dijit.form.Button");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.SimpleTextarea");

dojo.declare("xrxa.InsertTextButton", dijit.form.Button,
{
    constructor : function(params){
    
    this.id = params.id;
    


    	
	this.annotationControl = params.annotationControl;
	
	this.iconClass = "dijitEditorIcon dijitEditorIconPaste";
	this.inherited(arguments);
	
    //dummy here. see onClick
    this.createDialog();
  },
	
  postCreate : function(){	
	  
	  tooltip = 'Bitte Verwenden Sie für das Einfügen von Texten AUSSCHLIESSLICH diesen Einfüge-Button.\n For inserting text please use only this INSERT button.';
	  
	  this.connect(this.domNode, "onclick", "onClick");
	  dojo.attr(this.domNode, 'title', tooltip);
	  dojo.addClass(this.domNode, 'xrxaInsertTextButton');
	  this.inherited(arguments);
	  
	  
  },
  
  onClick: function(){

	  if(this.dialog == undefined){
		  this.createDialog();
	  }
	  
	  //console.log('InsertTextbutton.onClick', this);
  
	  if(!this.disabled){
		  this.dialog.show(); 
	  }

	  
	},
  
  createDialog : function(){
	  this.dialog = new dijit.Dialog({
	        title: "Insert Text",
	        style: "width: 560px; background-color:white;"
	    });
	  
	  dojo.addClass(this.dialog, 'xrxaInsertTextDialog');
	  
  
	  this.createTextarea();
	  this.createOk();
  },
  
  createTextarea : function(){
	  this.textarea = new dijit.form.SimpleTextarea({
		    name: "insertionTextarea",

		  });
	  
	  
	  dojo.addClass(this.textarea.domNode, 'xrxaInsertTextarea');
	  dojo.style(this.textarea.domNode, 'width', '550px');
	  dojo.style(this.textarea.domNode, 'height', '500px');
	  dojo.place(this.textarea.domNode, this.dialog.domNode);  
	  
	  
	  //for the right position
	  var div = dojo.create('div');
	  dojo.place(div, this.dialog.domNode);
  },
  
  createOk : function(){

	  var insertButton = dojo.create('button');
	  dojo.style(insertButton, 'float', 'right');
	  insertButton.innerHTML = 'OK';
	  dojo.connect(insertButton, "onclick", this.annotationControl, 'insertText'); 
	  dojo.connect(insertButton, "onclick", this.dialog, 'hide'); 
	  
	  dojo.place(insertButton, this.dialog.domNode);
  },
  
  getText : function(){
	  return this.textarea.getValue();
  },
  
  disableInsertButton : function(){
	  dojo.attr(this.domNode, 'disabled', 'true');	
	  this.set('disabled', true);
	  //console.log('InsertText.disableInsertButton', this.domNode);
  }, 
  
  clear : function(){
	  return this.textarea.setValue('');
  },
  
  enableInsertButton : function(){
	  dojo.removeAttr(this.domNode, 'disabled');
	  this.set('disabled', false);
	  //console.log('InsertText.enableInsertButton', this.domNode);
  },
  
  
  
  
});
