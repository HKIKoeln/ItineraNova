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

dojo.provide('xrxa.StartTag');

dojo.require('dijit._Widget');
dojo.require("xrxa.util");
dojo.require("xrxa.Attributes");
dojo.require("xrxa.DeleteElementButton");


dojo.declare("xrxa.StartTag", dijit._Widget,
{
  constructor : function(params){
	  
	 
	  this.id = params.id;
	  
	  
	  this.xmlDomNode = params.xmlDomNode;
	  
	  this.labelname =params.labelname;
	  this.elementname = params.elementname;  
	  
	  this.specializingAttribute = params.specializingAttribute;
	 
	  this.element = params.element;
	  
	  this.editor = params.editor;
	 
  },

  postCreate : function()
  {	
 
	if(this.xmlDomNode){			
			this.elementname = xrxa.getNodeName(this.xmlDomNode);			
	}  

	
	if(!this.labelname){
		this.labelname = xrxa.getLocalNodeNameByName(this.elementname);
	}
	
	  
	this.domNode = this.createStartTagSpan();
	this.connect(this.label, "onmouseup", "onClick"); 

	
	this.domNode.addEventListener ('DOMNodeRemoved', this.tagDeleted, false);

	   
  },
  
  //could be used as one method if superclass tag exists 
  tagDeleted: function(event) {
     
	  console.log('StartTag.tagDeleted', event);
	  
      if(event.relatedNode.id){
    	  var annotation = dijit.byId(event.relatedNode.id);
    	  console.log('StartTag.tagDeleted Remove Annotation', annotation, 'because Starttag was deleted');
    	  annotation.parentElement.content.removeAnnotation(annotation);
      }
  },
  
  /*OnNodeRemovedFromDocument: function(event) {
      console.log ('OnNodeRemovedFromDocument', event);
     
  },*/
  
//////////////////////////////HTML-NODES////////////////////////////////////
   
  createStartTagSpan : function(){	
	  
	  this.button = dojo.create("span" , {contenteditable: "false"}); 
	  dojo.addClass(this.button, 'xrxaStarttag');	  
	  this.createLabelSpan(this.labelname);
	  
	 
	  
	  this.createAttributesObject();
	  
	  return this.button;

    },
    
    createAttributesObject: function(){
    	 //Create Attributes-Object off xml-node
  	
    	
      if(this.xmlDomNode){
  		  this.attributesObject = new xrxa.Attributes({xmlDomNode: this.xmlDomNode, elementname: this.elementname, element: this.element, editor: this.editor});
    	  }
  	  //Create Attributes-Object off Specializing Attribute
  	  /*else if(this.labelname && this.specializingAttribute!=undefined){
  		  this.attributesObject = new xrxa.Attributes({elementname: this.elementname,  specializingAttribute: this.specializingAttribute, element: this.element, editor: this.editor});
  	  }*/
  	  //No Attributes set yet
  	  else if(this.labelname){
  		  this.attributesObject = new xrxa.Attributes({elementname: this.elementname, element: this.element, editor: this.editor});
  		 
  	  }
  	  dojo.place(this.attributesObject.domNode, this.button, 'last');
  	  
  	  console.log('StartTag.createAttributesObject', this.element);
 
    },
  
    //Creates a span-html-dom-node containing the label-name of the element
	 createLabelSpan: function(name){	
		 this.label = dojo.create("span");
		 dojo.addClass(this.label, 'xrxaTagLabel'); 
		 this.label.innerHTML = name;
		 dojo.place(this.label, this.button, 'first');
		 
	 },
	 
	 //Set or change the label-name of the element
	 setLabel: function(name){	
		 this.label.innerHTML = name;
		 
	 },
	 
//////////////////////////////XML-NODES////////////////////////////////////	 
  
   getXMLAttributes: function(mynode){		  
		  return  this.attributesObject.getXMLAttributes(mynode);
	 },

/////////////////////////////EVENTS//////////////////////////////////////////
  
  onClick: function(){

	  if(this.attributesObject == undefined){
		  this.createAttributesObject();
	  }
	  
	  this.attributesObject.toggleDisplay();
	  

	  
	  

	
		
	},
	

	
	

  

  

  
});
