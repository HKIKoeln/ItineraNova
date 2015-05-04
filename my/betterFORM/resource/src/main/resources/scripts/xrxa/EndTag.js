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

dojo.provide('xrxa.EndTag');

dojo.require('dijit._Widget');
dojo.require("xrxa.util");

dojo.declare("xrxa.EndTag", dijit._Widget,
{
  constructor : function(params){
	  
	  this.id = params.id;
	  
	  this.element = params.element;
	  
	  
	  this.labelname =params.labelname;
	  this.elementname = params.elementname;
	  
	//Default label-name is the element's local name
		if(!this.labelname){
			this.labelname = xrxa.getLocalNodeNameByName(this.elementname);
		}
	 
  },

  postCreate : function()
  {	
	this.domNode = this.createEndTagSpan();
    this.connect(this.domNode, "onmouseup", "onClick");   
    this.domNode.addEventListener ('DOMNodeRemoved', this.tagDeleted, false);

  },
  
  
   
  createEndTagSpan : function()
  {	
	  this.button = dojo.create("span" , {contenteditable: "false"});
	  dojo.addClass(this.button, 'xrxaEndtag'); 
	  //this.setLabel(this.labelname);
	  this.createLabelSpan(this.labelname);
	  return this.button;
  },
  
  createLabelSpan: function(name){	

	  	this.label = dojo.create("span");
	  	 dojo.addClass(this.label, 'xrxaTagLabel'); 
		 this.label.innerHTML = name;
		 dojo.place(this.label, this.button, 'first');
		 
	 },
  
  setLabel: function(name){	
		 this.button.innerHTML = name;
		 
  },  
 
//could be used as one method if superclass tag exists 
  tagDeleted: function(event) {
      if(event.relatedNode.id){

    	  var annotation = dijit.byId(event.relatedNode.id);
    	  console.log('StartTag.tagDeleted Remove Annotation', annotation, 'because Endtag was deleted');
    	  annotation.parentElement.content.removeAnnotation(annotation);
      }
   },
  
/////////////////////////////EVENTS//////////////////////////////////////////
  
  onClick: function(){
	  this.element.starttag.onClick();
	},
	
   
});
