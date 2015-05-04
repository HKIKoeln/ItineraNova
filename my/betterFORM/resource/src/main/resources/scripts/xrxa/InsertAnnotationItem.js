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

dojo.provide('xrxa.InsertAnnotationItem');

dojo.require('dijit.MenuItem');


dojo.declare("xrxa.InsertAnnotationItem", dijit.MenuItem,
{
  constructor : function(params){
	 
	  this.id = params.id;
	  
	  this.option = params.option;
	  this.selection = params.selection;
	  
	  //Pretty ugly way to get the label out of the xml meaning $option/xrxe:label/text()
	  //First child of option is a \n 
	  this.label = this.option.firstChild.nextSibling.firstChild.data;
	  
	  this.value = dojo.attr(this.option, 'value');
	  
	  //this.iconClass = "dijitEditorIcon dijitEditorIconSave";
	  
	  this.inherited(arguments);
	  

  },
	
  postCreate : function()
  {	
	  
	  //this.connect(this.domNode, "onclick", "onClick");
	  this.inherited(arguments);
	  
  },
  
 onClick: function(e){
	 
	
	  
	  elementname = this.getOnlyTagname(this.value);
	  
	  
	  //console.log('InsertAnnotationItem.onClick.elementname',elementname);
	  
	  fixedAttributes= this.getFixedAttribute(this.value);
	  //console.log('Options.onClick.fixedAttributes',fixedAttributes);
	  
	  
	  //Dirty Hack if the Selection MouseUp was down out of the AnnotationArea
	  //Get the Selection again
	  //No needed for correct work ???? Why
	  //this.selection.update();
	  
	  if(this.selection.addAnnotationPossible){			
		  	this.content = this.selection.getContent();
		  	this.content.insertAnnotation(this.selection, this.label, elementname, fixedAttributes);
	  }
	  else{
		  console.log('Option.onClick Annotation not possible', this.selection);
	  }

	 	
  },
  
  getOnlyTagname: function(xpath){
	  //console.log('getOnlyTagname', xpath, xpath.split('@')[0]);
	  return xpath.split('@')[0];
  },
  
  getFixedAttribute: function(xpath){
	  //console.log('getFixedAttribute', xpath, xpath.split('@')[1]);
	  return xpath.split('@')[1];
  },
  
  
  
  
  
  
  
});
