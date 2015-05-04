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

dojo.provide('xrxa.Text');
dojo.require('dijit._Widget');



dojo.declare("xrxa.Text", dijit._Widget,
{
  constructor : function(params){
	  
	  this.xmlDomNode = params.xmlDomNode;
	  this.dummy = params.dummy;
	  if(this.dummy==true){
		  this.string = '\u00a0';
	  }
	  else{
		  this.string = params.string; 
	  }
	  this.parentElement = params.parent;
	  
	  this.serializer = new XMLSerializer();
  },
  

  postCreate : function()
  {	
	  if(this.xmlDomNode){
		  this.domNode = this.xmlDomNode.cloneNode(true);
	  }
	  else if(this.string){
		  this.domNode = dojo.doc.createTextNode(this.string);
	  }
	  //console.log('Text.postCreate.domNode',this.domNode);
	  
	  this.domNode.addEventListener ('DOMNodeRemoved', this.deleted, false);
	  
	  
		this.connect(this.domNode.parent, "onclick", "onClick");
		this.connect(this.domNode.parent, "onpaste", "handlePaste");
		this.connect(this.domNode.parent, "onkeydown", "onKeyDown");
		this.connect(this.domNode.parent, "onkeypress", "onKeyPress");
  },
  
  handlePaste: function(e) {	 
	 
	 
  },
  
  /*
   * 
   *  postCreate : function()
  {	


	  
	  this.domNode = dojo.create("span");
	  dojo.addClass(this.domNode, 'xrxaText'); 
	  
	  if(this.xmlDomNode){
		  
		  dojo.place(this.xmlDomNode.cloneNode(true), this.domNode);
		  console.log('Text.postCreate place xmlDomNode', this.xmlDomNode, this.domNode);
	  }
	  else if(this.string){
		  dojo.place(dojo.doc.createTextNode(this.string), this.domNode);
	  }	    
	  
	  this.domNode.addEventListener ('DOMNodeRemoved', this.deleted, false);
	  

  },
  
  getXMLNode : function(){

	  var text = this.getText(this.domNode);
	  if(this.dummy==true & text=="\u00a0"){
		  return null;
	  }
	  else{
		  return dojo.doc.createTextNode(text);
	  }

  },
  
  getText : function(node){
	  var text = '';	  
	  for(var i=0; i<node.childNodes.length; i++){	
		  
		  var childNode = node.childNodes[i];
		  if(childNode.nodeType==1){  
			  text = text + this.getText(childNode);
		  }
		  else if(childNode.nodeType==3){
			  text = text + childNode.nodeValue;
		  }
			 
	  }
	  return text;	  
	  
  },
   */
  
  deleted: function(event) {	 
	  //in here this is the deleted domNode not the Text object 
	  console.log('Text.deleted', this);
	  var content = dijit.byId(event.relatedNode.id);
	  content.removeObjects.push(this);
	  console.log('Text.deleted.content.remove', content.removeObjects);
	  content.removeDeletedObjects();
	 
  },
  

  
  update: function(){

  },
  
  getXMLNode : function(){

	  var retur = this.domNode.cloneNode(true);
	  
	  
	  if(this.dummy==true & this.domNode.textContent=="\u00a0"){
		  //console.log('Text.getXMLNode .dummy==true ', this.domNode);
		  return null;
	  }
	  retur.data = retur.data.replace("\u00a0", ' ');
	  
	  return retur
  },
  
  getOuterXML : function(){
	  if(this.dummy==true & this.domNode.textContent=="\u00a0"){
		  return '';
	  }
	  //returns the outerXML althought be called innerXML
	  var outerXML  = this.serializer.serializeToString(this.domNode);
	  return outerXML;
  },
  
  isTextDummy : function(){
	  if(this.dummy==true){
		  if(this.domNode.textContent=="\u00a0"){
			  return true;
		  }
		  else{
			  console.log('Text.isTextDummy not dummy anymore', this.domNode.textContent, this)
			  return false;
		  }
		  
	  }
	  else{
		  return false;
	  }
  },
  
 
  

  
  setParent: function(newParent){
	  this.parentElement = newParent;
  },
  
  getParent: function(){
	  return this.parentElement;
  },
  
  
  
});
