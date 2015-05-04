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

dojo.provide('xrxa.Content');

dojo.require("xrxa.util");
dojo.require('xrxa.Annotation');
dojo.require('xrxa.Text');

dojo.declare("xrxa.Content", dijit._Widget,
{
  constructor : function(params){
	  
	  this.id = params.id;
	  	  
	  this.annotationControl = params.editor;
	  
	  //The Element-Object that content is represented
	  this.element = params.element;	 
	  
	  this.htmlTag = params.htmlTag;	  
	   
	  this.childObjects = new Array();
	  this.removeObjects = new Array();
	  
	  //node to hold the xml-value 
	  this.xmlNode = params.xmlnode;	 	  
	  if(!this.xmlNode){
		  this.xmlNode = this.createXMLNode();
	  }	 
	 
  },
  
  //creates an empty xml-node with the nodename of the element that is used to hold the xml-value
  createXMLNode: function(){
	  
	  //TODO: Destory this, be sure to have a name at any time
	  var name;
	  if(this.element.elementname){		  
		  name = this.element.elementname

	  }
	  else{
		  name =  this.element.localName;

	  }	

	  var xmlNode = dojo.doc.createElementNS(this.element.namespace, name);

	 
  

	  return xmlNode;
  },
  
  postCreate : function()
  {	
	  this.createDomNode();
	  //TODO: insert here: this.build();
  },
  
  createDomNode : function(){
	  
	  
	  if(!this.htmlTag){
		  this.htmlTag = 'span';
	  }
	  
	  this.domNode = dojo.create(this.htmlTag, {id: this.id});	 
	  dojo.addClass(this.domNode, 'xrxaContent');
  },
  
 
	
	build : function (){
		
		

		  traverse = function(childNode, content, i){
			  	if(childNode.nodeType==1){  
			   	  	 if(i==0 || content.previous == 'element'){					
						  content.createTextDummy();
						  //console.log('Content.build created Textdummy before', childNode);
					 }
				   	 			   	  	 
			   	  	 child = new xrxa.Annotation({xmlnode: childNode, parentElement: content.element, editor: content.annotationControl}); 
			   	  	 content.pushChild(child);
			   	  
			   	  	 if(i==(content.xmlNode.childNodes.length)-1){
						  content.createTextDummy();
						  //console.log('Content.build created Textdummy after', childNode, ' at last');
					 }
			   	  	 content.previous = 'element';
			  	  }
			  	  else if(childNode.nodeType==3){
			  		  child = new xrxa.Text({xmlDomNode: childNode, parentElement:content.element});
			  		  content.pushChild(child);
			  		  content.previous = 'text';
			  	  }
		   	  	
			}		  
	  
		  this.previous = '';			
		  for(var i=0; i<this.xmlNode.childNodes.length; i++){		    	
			  	traverse(this.xmlNode.childNodes[i], this, i);
		    }
		  
		  //NO CONETNET 
		  if(this.xmlNode.childNodes.length==0){
		    	this.createTextDummy();
		    	 //console.log('Content.build created Textdummy in Content', this);
		  }
		  
		  //console.log('Content.build - End - this.childObjects', this.childObjects);
		  //console.log('Content.build - End - childObjects count and show childObjects', this.childObjects.length, this.showChildObjects());
	  }, 	  
	
	pushChild: function(child){
		this.childObjects.push(child);	
		dojo.place(child.domNode, this.domNode, "last");

	},
	
	//creates a dummy TextObject with the Content ' ' so that the Annotation can be filled with Text
	createTextDummy: function(){
		 dummy = new xrxa.Text({dummy: true, parentElement:this.element});
		 this.pushChild(dummy);
		 //console.log('Content.createTextDummy',  this.showChildObjects())
	},
	
	//used for better displaying while debugging
	showChildObjects: function(){
		var show = new Array();
			for(var i=0; i<this.childObjects.length; i++){			 
				if(this.childObjects[i].declaredClass=='xrxa.Text'){
					show.push(this.childObjects[i].domNode.data);
				}
				else if(this.childObjects[i].declaredClass=='xrxa.Annotation'){
					show.push(this.childObjects[i].elementname);
				}
				
			}
		return show;
	},
	
	//If all the Content has been deleted, a textdummy is created onBlur to enable to click into the content again
	handleEmpty: function(){
		
		if(this.childObjects.length==0  || (this.childObjects.length==1 && this.childObjects[0].declaredClass=='xrxa.Text' && (this.childObjects[0].domNode.data==' ' || this.childObjects[0].domNode.data==''))){
			//console.log('Content.handleEmpty', this.childObjects.length, this.childObjects);
			this.childObjects = new Array();
			this.createTextDummy();
		}
		
	
	},

  	

	  
	//MOVE TO UTIL and use it in TEXT.deleted
	//TODO: Check if ther's a native dojo/javascript method to get the index
	  getIndex: function(childobject){
		  for(var i=0; i<this.childObjects.length; i++){
			  if(this.childObjects[i]==childobject){
				  return i
			  }
		  }
	  },
	  
	  //called in Text.deleted
	  deleteChildObject: function(child){
			index = this.getIndex(child);
			//console.log('Content.deleteChild at', index, child);
  	  		this.childObjects.splice(index, 1);
	  },
	  
	  createSelectionText: function (startText){		  
	  
		  startTextNode= dojo.doc.createTextNode(startText);
  		  startTextObject = new xrxa.Text({xmlDomNode: startTextNode, parentElement:this.element});
  		  this.childObjects.push(startTextObject);
  		  dojo.place(startTextObject.domNode, this.domNode, "last");	
  		  //this.childHTML.push(startTextObject.domNode);
  		  
	  },
	  
	  createEndOfSelectionText: function (endText){
		  endTextNode= dojo.doc.createTextNode(endText);
		  endTextObject = new xrxa.Text({xmlDomNode: endTextNode, parentElement:this.element});
		  this.childObjects.push(endTextObject);
		  dojo.place(endTextObject.domNode, this.domNode, "last");
		  //this.childHTML.push(endTextObject.domNode);
	  },
	  
	  update : function(){
	  	  //console.log('Content.update');
	      
	  	  //Create the current xml-node by objects
	  	  this.getXMLChildren();
	  	  //console.log('content.update.xmlNode', this.xmlNode);
	  	  	  	  
	  	  //Clean Arrays an domNode
	  	  this.clean();	 
	  	  //console.log('content.update - cleand');
	  	  
	  	  //rebuild the content by xml-node
	  	  this.build();
	  	  
	  	  //console.log('--------------------------Content.update', this.xmlNode);

	    },
	 
	  
	  //rebuilds the xmlNode 
	  getXMLChildren : function(){				  
  
		  //console.log('Content.getXMLChildren');
	  
		  this.preprocessObjects();	
		  
		  dojo.destroy(this.xmlNode);
		  
		  this.xmlNode = this.createXMLNode();
		  
		  for(var i=0; i<this.childObjects.length; i++){			  		
			  		xmlChild = this.childObjects[i].getXMLNode();
			  		//console.log('Content.getXMLChildren', i, xmlChild, this.childObjects[i]);	
		    		if(xmlChild){
		    			dojo.place(xmlChild, this.xmlNode);
		    			//console.log('Content.getXMLChildren.xmlNode', this.xmlNode);
		    		}
		    		else{
		    			//console.log('Content.getXMLChildren ignore Textdummy at', i);
		    		}
		    	
		 }
		 //console.log('#########################Content.getXMLChildren', this.xmlNode);
		 return this.xmlNode;
	  },
	  
	  getInnerXML : function(){
		  this.preprocessObjects();	
		  
		  var innerXML = ''		  
		  for(var i=0; i<this.childObjects.length; i++){
	    			innerXML = innerXML + this.childObjects[i].getOuterXML();
		  }
		  return innerXML;
	  },
	  
	 
	
	  preprocessObjects: function(){
		  
		  //can't remove textdummys here. They will be missing when inserting an annotation. Leave the TextDummyObjects and just don't give back an xml-node like it was once
		  //this.removeTextDummys();

		  this.insertNonXRXAText();

		  while(this.joinTextSiblings()){
		  }		  
	 
	 },
	 
	 
	 //not used at the moment
	 removeTextDummys : function(){
		 for(var i=0; i<this.childObjects.length; i++){
			 if(this.childObjects[i].declaredClass=='xrxa.Text'){
				 if(this.childObjects[i].isTextDummy()){
				 //console.log('Content.removeTextDummys', this.childObjects[i], 'removed', this.childObjects.length);
				 this.childObjects.splice(i, 1);		
				 }
			 }
		 }
	  },
	  
	  //When the whole Text of a xrxa.Text.domNode is deleted, the Object still exists in the Object-Array.
	  //Delete these deleted Objects
	  /*removeDeletedObjects: function(){
		
		  for(var i=0; i<this.childObjects.length; i++){
				 
				 if(this.childObjects[i].domNode.parentNode==null){
					 console.log('Content.removeDeletedObjects.childObject', i , this.childObjects[i].domNode,  this.childObjects[i].domNode.parentNode, this.childObjects[i]);
					 //this.childObjects.splice(i, 1);		
				 }
		  }
		  console.log('Content.removeDeletedObjects -end ', this.childObjects.length, this.childObjects);
	  },*/
	  
	  removeDeletedObjects: function(){
			 
		  var remove = new Array();
		  
		  //Find the Object of the deleted textNode and store it in the remove array
		  for(var i=0; i<this.childObjects.length; i++){
				 for(var j=0; j<this.removeObjects.length; j++){
					 if(this.childObjects[i].domNode==this.removeObjects[j]){
						 //console.log('Content.removeDeletedObjects Found Object to remove ', i,  this.childObjects[i].domNode, this.childObjects[i]);
						 remove.push(i);
						 //this.childObjects.splice(i, 1);		
					 }
			  }
		  }
		  
		  for(var i=0; i<remove.length; i++){
			  //console.log('Content.removeDeletedObjects remove', remove[i], this.childObjects[remove[i]]);
			  this.childObjects.splice(remove[i], 1);		
		  }
		  
		  //console.log('Content.removeDeletedObjects -end ', this.childObjects.length, this.childObjects);
		  this.removeObjects = new Array();

	  },
	  
	  
	  //After deleteing the whole content of a annotation control and typing text into it, the text is not wrapped in an xrxa.Text-Object. 
	  //In this case the textNodes become xrxa.Text-Objects, all other HTML-Element inserted by the Browser like <br type="moz_dirty"> are ignored 
	  insertNonXRXAText : function(){
		  if (this.childObjects.length==0 & this.domNode.childNodes.length!=0){
				var insert = new Array();
				var nonXRXA = this.domNode.cloneNode(true).childNodes
				
				dojo.empty(this.domNode);
				
				for(var i=0; i<nonXRXA.length; i++){		
					
					var node = nonXRXA[i];
					if(node.nodeType==3){  
						insertText =  new xrxa.Text({xmlDomNode: node, parentElement:this.element}); 
						//console.log('Content.insertNonXRXAText - insert', node, insertText);
						insert.push(insertText);
					}
					else{
						//console.log('Content.insertNonXRXAText - ignored non xrxa element', node);
					}
			    }
				for(var i=0; i<insert.length; i++){						
					this.pushChild(insert[i]);
				}  
				//console.log('Content.insertNonXRXAText -end ', this.childObjects.length, this.childObjects);
			}  
	  },
	 
	   //When removing an annotation several textnodes are following each other. These are put together to one textnode within one text-object
	  joinTextSiblings : function(){
		    for(var i=0; i<this.childObjects.length; i++){
		       	if(this.childObjects[i].declaredClass=='xrxa.Text'){
		    		j=i+1;
		    		if(this.childObjects[j]){
			    		if(this.childObjects[j].declaredClass=='xrxa.Text'){
			    			jointText = this.childObjects[i].domNode.nodeValue + this.childObjects[j].domNode.nodeValue;
			  			  	
			    			jointTextNode = dojo.doc.createTextNode(jointText);
			  			  	//console.log('Content.joinTextSiblings.node ', jointTextNode);
			  			  	
			  			  	jointTextObject =  new xrxa.Text({xmlDomNode: jointTextNode, parentElement:this.element}); 
			  			  	this.childObjects.splice(i, 2, jointTextObject);
			  			  	//console.log('Content.joinTextSiblings.object ', jointTextNode);
			  			  	
			  			  	return true;
			    		}
		    		}
		    	}
		    }		    
		    return false;
	  },
	  
	  //if a dom-node of a object was deleted with del or <- then remove the object from the array
	 
	  
	//If the Content Text has first been deleted totally and then was written again, the new Text is no TextObject, So if the Content is emnpty, check if Text is inside and create a TextObject  
	  addContainedText : function(){	
		//console.log('Content.addContainedText', this.domNode.childNodes.length);
		//console.log('Content.addContainedText.childObjects', this.childObjects);
	  	if (this.childObjects.length==0 & this.domNode.childNodes.length!=0)
  		{	
	  	//console.log('Console.addContainedText.childNodes', this.domNode.childNodes);
	  	//this.xmlNode.innerHTML = this.domNode.innerHTML;

	  	//this.build();
  		}
	  	 
	    },
	    

	    //called in xrxa.DeleteElementButton
	    //called in cdu.StartTag.tagDeleted
	    //Parent Node deletes Child Node
	    removeAnnotation : function(annotation){
	  	  

	      var index = this.getIndex(annotation);	  

	  	 
	      /*
	  	  var childrenToAdopt = annotation.content.childObjects;
	  	  var num = childrenToAdopt.length;
	  	  
	  	  for(var i=0; i<num; i++){
	  		console.log('####Content.removeAnnotation adopt', i, childrenToAdopt[i]);
	  		//childrenToAdopt[i].setParent(this.element);
	  	  }
	  	 //this.childObjects.splice(index, num, childrenToAdopt);
	  	 */ 
	  	  
	      
	  	  if(annotation.content.childObjects[0]){
	  		//!!!!!!!!!!!!!!!!!!! Works as long as only one grandchild object exists. i.g. all inner annotations are deleted before	  
		  	  var textToAdopt = annotation.content.childObjects[0];
		  	  
		  	//Remove Textdummy
		  	  	if(textToAdopt.dummy==true){
		  	  		this.childObjects.splice(index, 1);
		  	  		//console.log('After splice this.childObjects', this.childObjects);
		  	  	}
		  	  	//Keep contained Text as Child of Parentelement
		  	  	else{	  		
		  	  		textToAdopt.setParent(this.element);		  	
		  	  		this.childObjects.splice(index, 1, textToAdopt);
		  	  	}
	  	  }
	  	  else{
	  		this.childObjects.splice(index, 1);
	  	  }
	  	  
	  	  
	  	  
	  	  
	  	  
	  	  	
	  	  this.update();
	    },
	    
	    //deletes the domNode and all childobjects of the element
		  clean : function(){
			  
			  //Destroy all inner Widgets
			  for(var i=0; i<this.childObjects.length; i++){				  
				  this.childObjects[i].destroyRecursive();
			  }
			  
			  this.childObjects = new Array();
			  
			  //should be empty from destroyRecursive, but just to be sure
			  dojo.empty(this.domNode);
		  },
	    
	    
  
	   
	    //called in xrxa.Option
	    insertAnnotation : function(selection, labelname, elementname, specializingAttribute){		
	    	
	    	//when inserting text into a emty dummy the startText has to be updated
	    	//selection.update();
	    	
	    	//console.log('Content.insertAnnotation.selection', selection, labelname, elementname, this.domNode, this.childObjects.length, this.childObjects);
	  	  	//console.log('Content.insertAnnotation.showChildObjects', this.showChildObjects());
	  	  	//TEXT IN FRONT OF THE SELECTION/ANNOTATION 
	  	  	textInFrontOfAnnotation= dojo.doc.createTextNode(selection.startTextBefore);
	  	  	
	  		//TODO: CHECK
	  	  	if(textInFrontOfAnnotation.data==''){	  		
	  	  		var textObjectInFrontOfAnnotation = new xrxa.Text({dummy: true, parentElement:this.element});
	  	  		//console.log('Annotation.addAnnotation dummy before added Element')
	  	  	}
	  	  	else{
	  	  		//console.log('Annotation.addAnnotation berfore kein dummy', textInFrontOfAnnotation)
	  	  		textObjectInFrontOfAnnotation = new xrxa.Text({xmlDomNode: textInFrontOfAnnotation, parentElement:this.element});
	  	  		//console.log('Annotation.addAnnotation textObject in front of annotation', textInFrontOfAnnotation)
	  	  	}	  	  	
	  	  	
	  	  	//SELECTION/ANNOTATION 
	  	  	//console.log('Content.insertAnnotation.elementname', elementname);
	  	  	var annotation = new xrxa.Annotation({startText: selection.startTextAfter, containedObjects: selection.selectedAnnotations, endText: selection.endTextBefore, labelname: labelname, elementname: elementname, specializingAttribute: specializingAttribute, parentElement: this.element, editor: this.annotationControl});
	  	  	
	  	    
	  	  	//TEXT BEHIND THE SELECTION/ANNOTATION 
	  	  	var textBehindAnnotation= dojo.doc.createTextNode(selection.endTextAfter);
	  	  	
	  		//TODO: CHECK
	  	  	if(textBehindAnnotation.data==''){	  		
	  	  		textObjectBehindAnnotation = new xrxa.Text({dummy: true, parentElement:this.element});
	  	  		//console.log('Annotation.addAnnotation dummy after added Element')
	  	  	}
	  	  	else{
	  	  		//console.log('Annotation.addAnnotation after kein dummy', textBehindAnnotation)
	  	  		textObjectBehindAnnotation = new xrxa.Text({xmlDomNode: textBehindAnnotation, parentElement:this.element});
	  	  		//console.log('Annotation.addAnnotation textObject behind of annotation', textBehindAnnotation)
	  	  	}
	  	  
	  	  
	  	  	
	  	  	//TODO: CHECK
	  	  	//selected Objects are deleted from the Array and the new Objects are inserted
	  	  	selectionStartIndex = selection.getSelectionStartIndex();
	  	  	selectionEndIndex = selection.getSelectionEndIndex();
	  	  	numDeleteObjects = selectionEndIndex-selectionStartIndex+1;
	  	  	
	  	    //console.log('Content.insertAnnotation.Selection', selection);
	  	    //console.log('Content.insertAnnotation.selection.startTextBefore', selection.startTextBefore);
	  	  
	  	  	//console.log('Content.insertAnnotation', selectionStartIndex, selectionEndIndex, numDeleteObjects);
	  	  	
	  	  		  	  	
	  	  	//console.log('Annotation.insertAnnotation.childObjects.splice', selectionStartIndex, numDeleteObjects, textObjectInFrontOfAnnotation, annotation, textObjectBehindAnnotation);
	  	  	this.childObjects.splice(selectionStartIndex, numDeleteObjects, textObjectInFrontOfAnnotation, annotation, textObjectBehindAnnotation);

	  	  	//console.log('Content.insertAnnotation - End - childObjects count and show childObjects', this.childObjects.length, this.showChildObjects());
	  	  	
	  	  	this.update();
	  	  	
	    },
	    
	    insertText: function(selection, text){
	  	  
	  	  //console.log('Selection.update.vor', selection.startTextBefore);
	  	  //console.log('Selection.update.selection', selection.startTextAfter);
	  	  //console.log('Selection.update.danach', selection.endTextAfter);
	  	  
	  	  textContent = selection.startTextBefore + text + selection.endTextAfter;
	  	  textNode= dojo.doc.createTextNode(textContent);
	  	  
	  	  textChild = new xrxa.Text({xmlDomNode: textNode, parentElement:content.element});
	  	  
	  	  
	  	  this.childObjects.splice(selection.getSelectionStartIndex(), 1, textChild);
	  	  this.update();
	  	  
	  	  //console.log('Content.insertText', textChild, this.childObjects);

	    },
	    
	    createSelectedContent: function(selectedText, selectedAnnotations, endText){
		  
	      //console.log('Content.selectedText', selectedText);
	    	
	  	  //Selected Text in front of selected Annotation or just the selected Text if no Annotation is selected
	    	  if(selectedText!=''){
	    		  this.createSelectionText(selectedText);	  		  
	    	  }
	    	 
	    	
	  	  //selected Annotations
	  	  for(var i=0; i<selectedAnnotations.length; i++){	  		  		
	  		  		selectedAnnotations[i].parentElement = this.element;	  		  		
	  		  		this.pushChild(selectedAnnotations[i]);
	  	 }
	  		  
	  	  //Selected Text behind selected Annotaions
	  	  if(endText!=''){
	  		  this.createEndOfSelectionText(endText);
	  	  }

	    	
	    },
	    
	    //called in DeleteButton
	    countContainedAnnotations : function(){
          var count = 0; 
          for(var i=0; i<this.childObjects.length; i++){
                if(this.childObjects[i].declaredClass=='xrxa.Annotation'){
                        count++;
                }
          }
         return count;
         },
         
         closeAllAttributes : function(){
        	 
        	 for(var i=0; i<this.childObjects.length; i++){			 
        		 if(this.childObjects[i].declaredClass=='xrxa.Annotation'){
        			 //this.childObjects[i].content.closeAllAttributes();
        			 
        			 
        			 if(this.childObjects[i].starttag.attributesObject){
        				 this.childObjects[i].starttag.attributesObject.close();
        			 }
        			 else{
        				 //console.log('Content.closeAllAttributes no attributeObject,', this.childObjects[i]);
        			 }
        			//alert(this.childObjects[i].starttag.attributesObject); 
 				}
 				
 			}
         },
  
 
  
});