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

dojo.provide("xrxa.AnnotationControl");

dojo.require("xrxa.util");
dojo.require("xrxa.Selection");
dojo.require("xrxa.Toolbar");
dojo.require("xrxa.Content");

dojo.require("dojox.xml.parser");

dojo.require("betterform.ui.ControlValue");

dojo.declare(
        "xrxa.AnnotationControl",
        betterform.ui.ControlValue,
{
        	
	constructor: function(params){		
	
				
		this.id = params.id;
		if(params && dojo.isString(params.value)){
			this.value = params.value;
		}		
		
		this.nodePath = params.nodepath;
		this.namespace = params.namespace;		
		this.rows = params.rows;
		this.nodename = params.nodename;	
		this.xsdloc = params.xsdloc;
		this.services = params.services;
		
		if (this.nodename){
			this.prefix =xrxa.getPrefix2(this.nodename);			
			this.localName = xrxa.getLocalName2(this.nodename);
		}	
				
		this.selection= new xrxa.Selection({annotationControl: this});
		this.serializer = new XMLSerializer();
		
		
	},

	baseClass: "dijitEditor",
	name: "",	
	height: "150px", 
	width: "800",
	disableSpellCheck: false,	
	

	buildRendering:function() {		
		this.domNode = this.srcNodeRef;
    },
        
    postMixInProperties:function() {	   
        this.inherited(arguments);
        this.applyProperties(dijit.byId(this.xfControlId), this.srcNodeRef);
    },
    
    postCreate: function(){
		
		/*if(dojo.isMoz==undefined){
			alert('This Editor is optimized and tested only for the Mozilla Firefox Browser yet. Please use Firefox to use this Editor!');
		}*/   	
    	
	
		this.inherited(arguments);	
		
		dojo.addClass(this.domNode, this.baseClass);
		dojo.addClass(this.domNode, 'xrxaAnnotationControl');
		
		
		/*Don't use this*/
		this.value = dijit._editor.getChildrenHtml(this.domNode);			
		this.domNode.innerHTML = "";		
				
		this.createAnnotationArea();
		
		this.header = new xrxa.Toolbar({annotationControl: this, id:this.id+'-toolbar', class: 'xrxaAnnotationHeader'});
		dojo.place(this.header.domNode, this.domNode, 'first');
		
	},
	

	//needed by betterFORM	
	getControlValue:function(){
    	return this.getXMLValue();
		
    },

     //needed by betterFORM
    _handleSetControlValue:function(value) {
    	this.setValue(value);
    },
	

	
	handlePaste : function(e){
		alert('Bitte Verwenden Sie für das Einfügen von Texten AUSSCHLIESSLICH den Einfüge-Button rechts oben. For inserting text please use only the INSERT button in the right upper corner.');
		e.preventDefault();
		
		//this.header.insertText.dialog.show();
		//this.header.insertText.textarea.focus();
		
		
	},


	
	createAnnotationArea: function(){		
		this.window = window;
		
		this.annotationArea = dojo.create("div", {id: this.id+"AnnotationArea", tabindex: '0', contentEditable: 'true', class: 'xrxaAnnotationArea', style: 'min-height:' + (10 * this.rows) + 'px;'});
		
		this.connect(this.annotationArea, "onmouseup", "onClick"); 	
		//this.connect(this.annotationArea, "onmouseout", "onMouseOut"); 	
		this.connect(this.annotationArea, "onkeydown", "onKeyDown");
		this.connect(this.annotationArea, "onkeypress", "onKeyPressed");
		this.connect(this.annotationArea, "onkeyup", "onKeyUp");
		//this.connect(this.annotationArea, "onblur", "onBlur");
		this.connect(this.annotationArea, "onpaste", "handlePaste");
		

		dojo.place(this.annotationArea, this.domNode);
		
		this.setContent();	
		
		this.annotationArea.focus();
		

		
	},
	
	
	
	setContent: function(){
		
		
		
		this.xmlValue = this.demaskXML(this.value);		
		
		this.xmlNode = dojo.doc.createElementNS(this.namespace, this.nodename);
		
		//Problem: we don't know the namespaces used within this content
		this.xmlNodeString = "<" + this.nodename  + ' xmlns:' + this.prefix + '="' + this.namespace + '" xmlns:xlink="http://www.w3.org/1999/xlink">' + this.xmlValue + "</" + this.nodename + '>'; 
		
		var xmlNodeDoc = dojox.xml.parser.parse(this.xmlNodeString);
		this.xmlNode = xmlNodeDoc.childNodes[0]
		
		
		this.content= new xrxa.Content({xmlnode:this.xmlNode, element:this, editor:this}); 			
		//TODO: Move into Content
		this.content.build();
		
		dojo.place(this.content.domNode, this.annotationArea);
		this.onDisplayChanged();

	},
	
	
    getXMLValue: function(){
		
		if(this.content){
			this.content.getXMLChildren();			
			this.xmlContent = this.content.getInnerXML();
		}
		else{
			//the getXMLValue is called before the content is set... for this case this else
			this.xmlContent = this.xml;
		}
		return this.xmlContent

	},

	
		

	onClick: function(e){		
		this.update();

		this.onDisplayChanged(e);
	},
	
	onMouseOut: function(e){		
		this.update();

	},

	
	onKeyDown: function(e){				
		
		//ENTER
		if(e.keyCode == 13){
			//console.log('AnnotationControl.onKeyDown', e.keyCode, 'stopEvent');
			dojo.stopEvent(e); 
		}
		
		
		return true;
	},
	
	onKeyPressed: function(){
		this.onDisplayChanged(); 
	},
	
	
	onKeyUp: function(e){
	//update after arrows + shift has been used to select
	if(e.keyCode == 16  | e.keyCode == 37  | e.keyCode == 38  | e.keyCode == 39  | e.keyCode == 40){
		//console.log('AnnotationControl.onKeyDown', e.keyCode, 'update');
		this.update();
		}

	},
    
    onFocus:function() {
    	//this.toggleHeader();
        this.handleOnFocus();
    },

    onBlur:function(){
    	//this.toggleHeader();
    	
    	this.content.closeAllAttributes();
    	
		this.inherited(arguments);
        this.handleOnBlur();
        
        this.content.handleEmpty();
   },
   
   update: function(){
		this.selection.update();
		//console.log('AnnotationControl.onClick.selection', this.selection);		
		//Update Header in selection? only if selection has changed
		this.header.update();
   },
   
   
   //not used at the moment
    toggleHeader: function(){
		  var display = dojo.attr(this.header.domNode, 'style');
		  display = display.replace(';', '').replace(/ /g, '');
			if(display=='display:none'){
				dojo.attr(this.header.domNode, 'style', 'display:block'); 
			}
			else{
				dojo.attr(this.header.domNode, 'style', 'display:none');
			}
	},
	   
   
	updateInterval: 200,
	_updateTimer: null,	

    onDisplayChanged: function(e){
    	if(this._updateTimer){
			clearTimeout(this._updateTimer);
		}
		if(!this._updateHandler){
			this._updateHandler = dojo.hitch(this,"onNormalizedDisplayChanged");
		}
		this._updateTimer = setTimeout(this._updateHandler, this.updateInterval);
        
        if(this.incremental){
            this.setControlValue();
        }
    },
    
    
    onNormalizedDisplayChanged: function(){
		delete this._updateTimer;
	},	
	
	
	
	demaskXML : function(value){
		value = value.replace(/&lt;/g, "<");
		value = value.replace(/&gt;/g, ">");
		value = value.replace(/&quot;/g, '"');

		return value;
	},	
    
    
    
    //could be a Method if AnnotationControl/AnnotationControl and Element/Annotation have the same super-class Element
    getContext: function(){
    	return this.nodename
    },
    
    insertText: function(){
    	
    	var text =  this.header.insertText.getText();
    	var currentContent = this.selection.getContent();
    	currentContent.insertText(this.selection, text);
    	var text =  this.header.insertText.clear();
    },
    
    getPath: function(){
  	  return this.nodePath;
    },
});


