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

dojo.provide('xrxa.TextInsertion');

dojo.require("dijit.Dialog");
dojo.require("dijit.form.SimpleTextarea");

dojo.declare("xrxa.TextInsertion", dijit._Widget,
{
    constructor : function(params){
    	
	this.annotationControl = params.annotationControl;
	
	
	
    
  },
	
  postCreate : function(){	
	  
  
	  this.domNode =  dojo.create('input');	
	  dojo.attr(this.domNode, 'type', 'image');
	  dojo.attr(this.domNode, 'src', 'http://aux.iconpedia.net/uploads/119653526.png');
	  dojo.attr(this.domNode, 'width', '20px');
	  dojo.attr(this.domNode, 'height', '20px');
	  dojo.style(this.domNode, 'float', 'right');
	  
	  //this.domNode.innerHTML = 'Insert';
	  
	  //var image = dojo.create('img');
	  //dojo.attr(image, 'src', './img/insertText.png');
	  
	  //<img src="selfhtml.gif" width="106" height="109" alt="SELFHTML Logo"><br>
	  
	  this.connect(this.domNode, "onclick", "onClick");
	  
	  //this.domNode

  },
  
  onClick: function(){

	  if(this.dialog == undefined){
		  this.createDialog();
	  }
	  
	  //console.log('Textinsertion.onClick', dojo.style(this.dialog, 'display'));
	  
	  this.dialog.show();
	  
	 
	  
	  
	  /*if(dojo.style(this.dialog, 'display')=='inline'){
		  dojo.style(this.dialog, 'display', 'none');
	  }
	  else if(dojo.style(this.dialog, 'display')=='none'){
		  dojo.style(this.dialog, 'display', 'inline');
	  }*/
	  
	  
	},
  
  createDialog : function(){
	  this.dialog = new dijit.Dialog({
	        title: "Insert Text",
	        style: "width: 560px; background-color:white;"
	    });
	  
	  dojo.addClass(this.dialog, 'xrxaInsertTextDialog');
	  
	  //this.dialog =  dojo.create('div');
	  //this.textarea = dojo.create('textarea');
	  
	  this.textarea = new dijit.form.SimpleTextarea({
		    name: "insertionTextarea",

		  });
	  
	  
	  dojo.addClass(this.textarea.domNode, 'xrxaInsertTextarea');
	  dojo.style(this.textarea.domNode, 'width', '550px');
	  dojo.style(this.textarea.domNode, 'height', '500px');
	  //dojo.attr(this.textarea.domNode, 'name', 'insertion');
	  //dojo.style(this.dialog, 'position', 'fixed');
	  //dojo.style(this.dialog, 'display', 'inline');
	  
	  //var inserButton = new dijit.form.Button()
	  
	  dojo.place(this.textarea.domNode, this.dialog.domNode);  
	  
	  
	  var div = dojo.create('div');
	  dojo.place(div, this.dialog.domNode);
	  
	  
	  var insertButton = dojo.create('button');
	  dojo.style(insertButton, 'float', 'right');
	  insertButton.innerHTML = 'OK';
	  dojo.connect(insertButton, "onclick", this.annotationControl, 'insertText'); 
	  dojo.connect(insertButton, "onclick", this.dialog, 'hide'); 
	  
	  dojo.place(insertButton, this.dialog.domNode);
	  //dojo.place(this.dialog, this.domNode, 'last');
  },
  
  getText : function(){
	  return this.textarea.getValue();
  },
  
  disableInsertButton : function(){
	  dojo.attr(this.domNode, 'disabled', 'true');	 
	  //console.log('TextInsertion.disableInsertButton', this.domNode);
  },
  
  clear : function(){
	  return this.textarea.setValue('');
  },
  
  enableInsertButton : function(){
	  dojo.removeAttr(this.domNode, 'disabled');
	 //console.log('TextInsertion.enableInsertButton', this.domNode);
  },
  
  
  
  
});
