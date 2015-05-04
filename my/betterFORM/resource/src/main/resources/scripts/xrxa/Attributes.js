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

dojo.provide('xrxa.Attributes');


dojo.require("dijit.form.Button");
dojo.require('dijit._Widget');

dojo.require("xrxa.Attribute");
dojo.require("xrxa.util");


dojo.declare("xrxa.Attributes", dijit._Widget,
{
  constructor : function(params){
	 
	  
	  
	  this.id = params.id;	  
	  this.xmlDomNode = params.xmlDomNode;	  
	  this.elementname = params.elementname;	  
	  this.annotationControl = params.editor;
	  this.element = params.element;
	  //this.specializingAttribute = params.specializingAttribute;
	  
	  this.attributeObjects = new Array();	  
	  
	  
  },

  postCreate : function()
  {	
    this.createAttributesSpan();
  },
  
  toggleDisplay: function(){
	  if(dojo.style(this.attributesSpan, 'display')!='none'){
		  this.close();
	  }
	  else if(dojo.style(this.attributesSpan, 'display')=='none'){
		  this.open();
	  }
	},
	
	close: function(){
		dojo.style(this.attributesSpan, 'display', 'none');
	},
	
	open : function(){
		this.annotationControl.content.closeAllAttributes();
		dojo.style(this.attributesSpan, 'display', 'inline');
	},
   


  createAttributesSpan : function()
  {
	  this.attributesSpan = dojo.create('span', {style: 'display:none', class: 'xrxaAttributes'});
	  this.createCloseButton();
	  this.createRemoveAnnotationButton();  
	  this.createAttributes();	  
	  this.domNode = this.attributesSpan;
  },  
 
  createCloseButton: function(){
	  this.closeButton = new dijit.form.Button({
		  label: "", 
		  showLabel: false, 
		  iconClass : "dijitEditorClose", 
		  class: "xrxaCloseAttributesButton"});
	  dojo.place(this.closeButton.domNode, this.attributesSpan, 'first');
	  this.connect(this.closeButton.domNode, "onmouseup", "close");
  },
  
  createRemoveAnnotationButton: function(){
	  this.removeAnnotationButton = new dijit.form.Button({
	        label: "Remove Annotation",
	        iconClass : "dijitEditorIcon dijitEditorIconDelete",
	        class : "xrxaRemoveAnnotationButton"
	    });    
	  dojo.place(this.removeAnnotationButton.domNode, this.attributesSpan, 'last');
	  this.connect(this.removeAnnotationButton.domNode, "onmouseup", "removeAnnotation");
  },
  
  removeAnnotation: function(){
		 /*if(this.element.content.countContainedAnnotations()>0){
				alert('Please delete all annotations within this annotation first!');
		 }
		  else{*/
			  this.element.parentElement.content.removeAnnotation(this.element);
		 //} 
	 },
  
  
   createAttributes: function(){

	  
	  var attributeObjects = this.attributeObjects;
	  var attributesSpan = this.attributesSpan;
	  var xmlDomNode = this.xmlDomNode
	  
	  
	  // existing attributes
	  /*if(this.xmlDomNode){
		  for(var i=0; i<this.xmlDomNode.attributes.length; i++){
			  //alert(this.xmlDomNode.attributes[i].nodeName);
			  attributeObject = new xrxa.Attribute({attributeDescription: this.xmlDomNode.attributes[i], xmlDomNode: this.xmlDomNode.attributes[i], attribute: this.xmlDomNode.attributes[i]});		
			  this.attributeObjects.push(attributeObject);			  
			  dojo.place(attributeObject.domNode, attributesSpan);		  
		  }
	  }*/
	  
	  ///////////////////////////////////////
	  
	  
	  // create Attribute off the specializing Attributename- and value
	  //specializing Attributes are not used at the moment. Should be reimplemented in qxrxe
	  /*
	  else if(this.specializingAttribute){

		  split_specializingAttribute = this.specializingAttribute.split('=');
		  specializingAttributeName = split_specializingAttribute[0];
		  specializingAttributeValue = split_specializingAttribute[1].replace('"', '').replace("'", "").replace('"', '').replace("'", "");
		  
		  attributeObject = new xrxa.Attribute({name: specializingAttributeName, value: specializingAttributeValue, fixed:true});		
		  this.attributeObjects.push(attributeObject);
		  dojo.place(attributeObject.domNode, this.attributesSpan);	
	  }
	  */
	  
	  /*console.log('-----------------------------------------------------------------------------');

	  dojo.xhrGet({
		  url: this.annotationControl.services + "?service=get-xrxe-attributes&context=" + this.element.getPath() + "&xsdloc=" + this.annotationControl.xsdloc,
	      handleAs: 'xml',	      
	      load: function(result){ 
	        	
	        	
	        	console.log('XRXRXRXRXRXRXREEEEE', result);
	  
	        }
		}); 
	  
	 */
	  //alert(this.element.getPath());

	  
	  //get non existing possible attributes by ajax
	  dojo.xhrGet({
		  url: this.annotationControl.services + "?service=get-attributes&context=" + this.elementname + "&xsdloc=" + this.annotationControl.xsdloc,
	      handleAs: 'xml',
	      
	        load: function(result){ 
	        	
	        	
	        	for(var i=0; i<result.firstChild.attributes.length; i++){
	        		
	        		attributeDescription = result.firstChild.attributes[i];
	        		
	        		//Has to be Changed
	        		attributeName = attributeDescription.nodeName;	        		
	        		attribute = xmlDomNode.getAttributeNode(attributeName)
	        		
	        		attributeObject = new xrxa.Attribute({attributeDescription: attributeDescription, attribute: attribute});		
	  			  	attributeObjects.push(attributeObject);			  
	  			  	dojo.place(attributeObject.domNode, attributesSpan);	
	  			  
	        		
	        		/*
	        		exists = false;
	        		for(var j=0; j<attributeObjects.length; j++){
	        			if(attributeObjects[j].name == result.firstChild.attributes[i].nodeName){
	        				exists = true;
	        			}
	        		}
	        		if(exists!=true){
	        			//add existing attributeNode as parameter
		        		attributeObject = new xrxa.Attribute({attributeDescription: result.firstChild.attributes[i], attribute: null});		
		  			  	attributeObjects.push(attributeObject);			  
		  			  	dojo.place(attributeObject.domNode, attributesSpan);	
	        		}
	        		else {
	        		
	        		}
	        		*/
	        		
	  
	        	}
	        }
		}); 
  },
  
//////////////////////////////XML-NODES////////////////////////////////////
  
  //returns attributes as xml-dom nodes cretaed off the -Object model
  getXMLAttributes: function(element){	  
	  
	  for(var i=0; i<this.attributeObjects.length; i++){		  
		  this.attributeObjects[i].getAttribute(element);
	  }	  
	  return element;
 },
 
 
  
});