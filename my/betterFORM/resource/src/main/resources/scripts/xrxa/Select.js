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

dojo.provide('xrxa.Select');

dojo.require('dijit._Widget');


dojo.declare("xrxa.Select", dijit._Widget,
{
  constructor : function(params){
	 
	this.name = params.name; 
	  

  },
	
  postCreate : function()
  {	
	  
	  select = dojo.create('select');		 
	  this.domNode = select
	  dojo.addClass(this.domNode, 'xrxaSelect');
	  dojo.attr(this.domNode, 'display', 'inline-block');
	  this.getOptions();
	  this.connect(this.domNode, "onmouseup", "onClick");
	  
	  
  },
  
  getOptions: function(){
	  

  },
  

  onClick: function(){

  },
  
  
  
  
  
});
