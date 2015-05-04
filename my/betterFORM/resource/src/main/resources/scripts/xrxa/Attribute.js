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

dojo.provide('xrxa.Attribute');

dojo.require('dijit._Widget');
dojo.require("xrxa.util");


dojo.declare("xrxa.Attribute", dijit._Widget,
{
  constructor : function(params){
	  
	 
	 
	  //this.id = params.id;
	  
	  this.attributeDescription = params.attributeDescription;
	  this.attribute = params.attribute;
	  
	  this.getAttributeProperties();
	  this.getAttributeStatus();
	  
	  //this.fixed = params.fixed;
	  
	  
  },
  
  getAttributeProperties : function(){
	  if(this.attributeDescription){		  
		  //has to be canged
		  this.name = this.attributeDescription.nodeName
		  this.localNamen ="";
		  this.prefix = "";
		  this.namespace = "";
		  this.type = "";
		  this.label= this.name;
	      this.controlName= "input";
	      this.defaultValue ="";
	      this.fixed = "";

	  }
	  
  },
  
  getAttributeStatus : function(){	 
	  
	  if(this.attribute){
		  this.value = this.attribute.nodeValue.replace(/"/g, '');
	  }
	  else
		  this.value="";
	  
  },

  postCreate : function(){	
     this.createAttributeSpan();    

  },
  
  //Creates a span-html-dom-node representing the attribute
  createAttributeSpan : function()
  {
	  
	  
	  this.attributeSpan = dojo.create('span', {class: 'xrxaAttribute'})	 
	  //Hide "xmlns" handled as attributes by Javascript
	  if(this.name.substring(0, 6)=='xmlns:'){		  
		  dojo.attr(this.attributeSpan, 'style', 'display:none;') ;
	  }
	  
	  this.createAttributeLabelSpan();	
	  this.createAttributeValueSpan();	
	  this.domNode = this.attributeSpan;
  },
    

  createAttributeLabelSpan : function()
  {
	  labelSpan = dojo.create('span', {class: 'xrxaAttributeName'});  
	  label = dojo.doc.createTextNode(this.label);	
	  dojo.place(label,  labelSpan);  
	  dojo.place(labelSpan,  this.attributeSpan);

  },
  

  createAttributeValueSpan : function()
  {
	  controlSpan = dojo.create('span')
	  dojo.addClass(controlSpan, 'xrxaAttributeValue');	
	  /*using this.controlName instead of 'input doesn't work. Why?'*/
	  this.control = dojo.create('input', {class: 'xrxaAttributeValueInput', value: this.value});
	  dojo.place(this.control, controlSpan);
	  dojo.place(controlSpan,  this.attributeSpan);
   },
  
	getName : function(){
		return this.name;
	},
	
	getPrefix : function(){
		var doublePointIndex = this.name.indexOf(':');
		var prefix
		if(doublePointIndex >= 0){
			prefix = this.name.substring(0, doublePointIndex);
		}
		else {
			prefix = null;
		}	
		return prefix;
	},
	
	getNamespace : function(){
		var namespace;
		var prefix = this.getPrefix();
		if(prefix){
			  if(prefix=='xlink'){
				 namespace="http://www.w3.org/1999/xlink";
			  }			  
		 }
		 else{
			  namespace=null;
		 }
		 return namespace;
	},
	
	getValue : function(){
		return this.control.value;
	},
	
	createAttribute : function(){
	 

		
	  if(this.getNamespace()){
			  this.attribute = dojo.doc.createAttributeNS(this.getNamespace(), this.name)
	  }
	  else{		  
		  this.attribute = dojo.doc.createAttribute(this.name);
	  }
	},
	
	setAttributeValue : function(){
		this.attribute.nodeValue = attributeValue;
	},
	
	
	
	getAttribute : function(element){		 
		  
		
		  attributeValue = this.getValue();
		  
		  //allow empty attributes when attributes can be deleted
		  if(attributeValue!=''){
			  
			  this.createAttribute();
			  this.setAttributeValue();
			  
			  element.attributes.setNamedItemNS(this.attribute);
			 
			 
		  }
	},
  
});


	
	


