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

dojo.provide('xrxa.Annotation');

dojo.require('dijit._Widget');

dojo.require("xrxa.util");
dojo.require('xrxa.StartTag');
dojo.require('xrxa.Content');
dojo.require('xrxa.EndTag');


dojo.declare("xrxa.Annotation", dijit._Widget,
{
  constructor : function(params){
	  
  
	  this.id = params.id;
	  this.xmlDomNode = params.xmlnode;	 	  
	  
	  this.startText =params.startText;
	  this.containedObjects = params.containedObjects
	  this.endText = params.endText;
	  
	  this.editor = params.editor;	  
	  
	  this.elementname = params.elementname;
	  //console.log('Annotation.constructor.elementname', this.elementname);
	  
	  this.labelname =params.labelname;	  
	  
	  this.specializingAttribute = params.specializingAttribute;	
	  
	  this.parentElement = params.parentElement;
	  
	  this.serializer = new XMLSerializer();
	  //console.log('__Annotation.constructor.serializer', this.serializer);
	  
	  this.namespace = params.namespace;
	  if(!this.namespace){
		  this.namespace = this.parentElement.namespace;
	  } 
	  //console.log('Annotation.constructor.namespace', this.namespace);
	 
  },
  
  handlePaste : function(e){
	  //alert('You have directly pasted text into the Control. This can lead to the loss of text fragments. Please reload the page and use the paste button on top of this control');
	  
  },
  
  onSelect: function(/*Event*/ e){		
		//alert('Annotation.onSelect');
		//this.update();

	},
  


  postCreate : function()
  {	
	//Two  Way how to build an Annotation. 
	//1. By xml-node when loading a AnnotationTextarea that contains mixed Contant 	
	if(this.xmlDomNode){	
		this.content = new xrxa.Content({xmlnode: this.xmlDomNode, element:this, editor: this.editor, domNode:this.domNode});
		this.buildAnnotation();
		
	}
	//2. By Selecting Text and adding an Annotation to the Content
	else if(!this.xmlDomNode){
		this.createAnnotation();
	}
	else{
		
	}
  },
  
  //could be a Method if XMLEditor/AnnotationControl and Annotation/Annotation have the same super-class Element
  getContext: function(){
  	return this.elementname;
  },
  
  buildAnnotation : function(){
	  
	   if(this.elementname=='' || this.elementname==undefined){
		   this.elementname = xrxa.getNodeName(this.xmlDomNode);	   
	   }
	   
	   
	   this.labelname = this.elementname;

	   this.domNode = this.createAnnotationSpan();
	   
	   this.connect(this.annotationArea, "onselect", "onSelect");
		
	    
	   this.createStartTag();
	    

	   this.content.build();	   
	   dojo.place(this.content.domNode, this.domNode, "last");	
	    
	    this.createEndTag();
	    
	   
	    //Label
	    var currentStartTag = this.starttag;
	    var currentEndTag = this.endtag;
	    var currentElement = this;

	    url = this.editor.services + "?service=get-label&context="+ this.elementname+ "&xsdloc=" + this.editor.xsdloc;
	    if(this.xmlDomNode.attributes.length != 0){
	   	   url = url + "&attrname="  + this.xmlDomNode.attributes[this.xmlDomNode.attributes.length-1].nodeName + "&attrvalue="  + this.xmlDomNode.attributes[this.xmlDomNode.attributes.length-1].nodeValue; //nodeValue sollte nichtmehr benutzt werden
	    }
	    
	    dojo.xhrGet({
	        url: url,
	        
	        load: function(result){ 
	        	currentStartTag.setLabel(result);
	        	currentEndTag.setLabel(result);
	        	currentElement.setLabel(result);
	        }
		}); 
  },
  
  createAnnotation : function()
  {
	  //console.log('Annotation.createAnnotation.elementname:', this.elementname, 'this.endText:-', this.endText, '-');
	  
	  this.domNode = this.createAnnotationSpan();	  
	  
	  this.createStartTag();
	  
	  
	  //CONTENT
	  this.content = new xrxa.Content({parent:this, editor: this.editor, domNode:this.domNode, element: this});
	  this.content.createSelectedContent(this.startText, this.containedObjects,  this.endText);	  
	  
	  dojo.place(this.content.domNode, this.domNode, 'last');	 
	  
	  //console.log('Annotation.createAnnotation.content.domNode',this.content.domNode);
	  
	  this.createEndTag();
  },
  

  createAnnotationSpan : function()
  {		
    span_node = dojo.create("span", {id: this.id});
    
    //, {title: this.labelname, class: 'xrxaAnnotation', namespace: xrxa.getNamespaceByName(this.elementname)}
    //, id: this.id
    dojo.addClass(span_node, 'xrxaAnnotation'); 
	return span_node;

  },
  
  createStartTag: function (){
	if(this.xmlDomNode){
		//Starttag
	   	this.starttag = new xrxa.StartTag({xmlDomNode: this.xmlDomNode, specializingAttribute: this.specializingAttribute, labelname: this.labelname, editor: this.editor, element: this});
	    dojo.place(this.starttag.domNode, this.domNode, "first");	
		
	}
	else{  
	//STARTTAG aus createAnnotation
	this.starttag = new xrxa.StartTag({elementname: this.elementname, labelname: this.labelname, specializingAttribute: this.specializingAttribute, element: this, editor: this.editor});
	dojo.place(this.starttag.domNode, this.domNode, "first");	
	}	  
	 
  },
  
  createEndTag: function (){
	  this.endtag = new xrxa.EndTag({elementname: this.elementname, labelname: this.labelname, element: this});
	  dojo.place(this.endtag.domNode, this.domNode, "last");
  },
  
  setLabel: function(name){	
	  	this.labelname = name;
  },  
  
  
 getXMLAttributes : function(){
	 if (this.starttag){
		  this.starttag.getXMLAttributes(this.xmlDomNode);  
	 }
	 
  },
  
  getXMLNode : function(){   

	  	this.xmlDomNode = this.content.getXMLChildren();
	  	//console.log('%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&Annotation.getXMLNode', this.xmlDomNode);
	  	this.getXMLAttributes();	  	
	    return this.xmlDomNode;
	  
  },
  
  getOuterXML : function(){
	  //returns the outerXML althought be called innerXML
	  var outerXML  = this.serializer.serializeToString(this.xmlDomNode);
	  return outerXML;
  },
  
  
  setParent: function(newParent){
	  this.parentElement = newParent;
  },
  
  getPath: function(){
	  return this.parentElement.getPath() + '/'+ this.xmlDomNode.nodeName;
  },
  
  
  
  
});
