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

/*########### DEPRECATED ###########*/
dojo.provide('xrxa.DeleteElementButton');


dojo.require("xrxa.util");
dojo.require('dijit._Widget');


dojo.declare("xrxa.DeleteElementButton", dijit._Widget,
{
    constructor : function(params){
    	
    	this.id = params.id;
    	
	this.element = params.element;
	//console.log('this.element in DeleteElementButton', this.element);
    
  },
	
  postCreate : function()
  {	
	  this.domNode = dojo.create('button');
	  dojo.addClass(this.domNode, 'xrxaDeleteElementButton');
	  this.domNode.innerHTML = 'delete';
	  this.connect(this.domNode, "onclick", "onClick");
  },
  
  
  
  onClick: function(e){
	 
	  //Disable Deletion if Selection contains Annotations
	  if(this.element.content.countContainedAnnotations()>0){
			alert('Please delete all annotations within this annotation first!');
	  }
	  else{

		  this.element.parentElement.content.removeAnnotation(this.element);
		  
		  //this.element.parent.childObjects.splice(myIndex, num_children , this.childObjects);

	  }
	  
	 
  },
  
  

 
  
  
  
  
  
});
