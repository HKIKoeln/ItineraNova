dojo.provide('xrxa.Selection');

dojo.require("dijit._editor.selection");
dojo.require("dijit._editor.range");


dojo.declare("xrxa.Selection", null,
{
  constructor : function(params){
	  this.annotationControl = params.annotationControl;
	  this.addAnnotationPossible = false;
	  
	  this.selectionStartIndex  = -1;
	  this.selectionEndIndex = -1;
	  
	  //TODO: set Default Content
  },
  
  //called in XMLEditor.onClick
  update: function(){  	  
	  
	  //alert('Selection.update');
	  
	  this.setHTMLSelection();
	  
	  this.setAnnotationPossible();
	  
	  this.setTextInsertionPossible();

	  this.setStartAndEndTextNodes();	 
	  
	  this.selectContentObject();	  

	  //Könnte mit setSelectedAnnotations zusammengefasst werden!!!
	  this.setIndexOfSelectionStartAndSelectionEnd();
	  
	  this.setSelectedAnnotations();
	  	  
	  this.setStartAndEndSeletionPosition();	  
	  
	  this.setStartAndEndSeletionText();	 
	  
	  this.cutText();
	  
	  //console.log('Selection.update', this);

	
  },
  
  setHTMLSelection: function(){
	  this.selection = dijit.range.getSelection(this.annotationControl.window);	 
	  
	  
	  this.anchor = this.selection.anchorNode;
	  this.focus = this.selection.focusNode;	 
  },
  
  //checks if the selection would create well-formed XML, (if all selected tags have their partner in the selection too)
  setAnnotationPossible: function(){  	  
	  
	  //console.log('Selection.setAnnotationPossible', this.anchor, this.focus);
	  
	  if(dojo.hasClass(this.anchor.parentNode, 'StartTag') | dojo.hasClass(this.anchor.parentNode, 'EndTag') | dojo.hasClass(this.anchor.parentNode, 'Attributes') | dojo.hasClass(this.anchor.parentNode, 'Attribute')| dojo.hasClass(this.anchor.parentNode, 'AttributeName') | dojo.hasClass(this.anchor.parentNode, 'AttributeValue')| dojo.hasClass(this.anchor.parentNode, 'AttributeValueInput')){
		  this.addAnnotationPossible = false; 
	  }
	  
	  else if (this.anchor.parentNode!=this.focus.parentNode){
		  	this.addAnnotationPossible = false;
		 }
	  else
	  {
		
		 if (this.anchor.nodeType!=3){			 
			 this.addAnnotationPossible = false;
		 }
		 else{
			 if (this.focus.nodeType!=3){
				 this.addAnnotationPossible = false;
			 }
			 else{
				 this.addAnnotationPossible = true;
			 }
		 }
	 }

  },
  
	setTextInsertionPossible: function(){  	  
		  if(this.anchor != this.focus | dojo.hasClass(this.anchor.parentNode, 'StartTag') | dojo.hasClass(this.anchor.parentNode, 'EndTag') | dojo.hasClass(this.anchor.parentNode, 'Attributes') | dojo.hasClass(this.anchor.parentNode, 'Attribute')| dojo.hasClass(this.anchor.parentNode, 'AttributeName') | dojo.hasClass(this.anchor.parentNode, 'AttributeValue')| dojo.hasClass(this.anchor.parentNode, 'AttributeValueInput')){
			  //this.textInsertionPossible = false; 
			  //this.annotationControl.header.textInsertion.disableInsertButton();
			  
			  this.annotationControl.header.insertText.disableInsertButton();
		  }
		  else{			  
			  //this.annotationControl.header.textInsertion.enableInsertButton();
			  
			this.annotationControl.header.insertText.enableInsertButton();
		  }
	  },
  
  leftToRight: function(anker ,focus){
	  var check=false;
      current = anker;
          var sibling ; 
          while(current.nextSibling!=null){             
        	  sibling = current.nextSibling;
              if (sibling==focus){
                  check=true;
                  break;
              }
              current=sibling;
          }
      return check;      
  }, 
  
  
  
  //get textnode the seletion starts in and the textnode the seletion ends in
  //not anchor and focus if selection started on the right side and moved to left
  setStartAndEndTextNodes: function(){
	  
	 

	  if(this.addAnnotationPossible){
		  
		  if(this.focus==this.anchor){
			  this.startNode = this.endNode = this.focus;
		  }
		  else{
			  if(this.leftToRight(this.anchor, this.focus)){
				 
				  this.startNode = this.anchor;
				  this.endNode = this.focus;
			  }
			  else{
				  this.startNode = this.focus;
				  this.endNode = this.anchor;
			  }			  
		  }
	  }
	  else{
		  this.startNode = null;
		  this.endNode = null;
	  }
  },
  
  setIndexOfSelectionStartAndSelectionEnd: function(){
	  
	  if(this.startNode!=null && this.endNode!=null && this.content){
		  //console.log('Selection.setIndexOfSelectionStartAndSelectionEnd', this.startNode, this.endNode);
		  for(var i=0; i<this.content.childObjects.length; i++){
			 
			  //if(this.content.childObjects[i].domNode.data==this.startNode.data){	
			  if(this.content.childObjects[i].domNode==this.startNode){	
				  this.selectionStartIndex = i;
				  //console.log('Selection.setIndexOfSelectionStartAndSelectionEnd.selectionStartIndex', i);
			  }
	 
			  //if(this.content.childObjects[i].domNode.data==this.endNode.data){	
			  if(this.content.childObjects[i].domNode==this.endNode){	
				  this.selectionEndIndex = i;
				  //console.log('Selection.setIndexOfSelectionStartAndSelectionEnd.selectionEndIndex', i);
			  }
		  }
	  }
  },
  
  setSelectedAnnotations: function(){
	  
	  this.selectedAnnotations = new Array();
	  
	  	  if(this.content){
	  		 for (i=this.selectionStartIndex+1; i<this.selectionEndIndex; i++){
				  this.selectedAnnotations.push(this.content.childObjects[i]);
			  }
	  	  }
	  },
	  
	  
  
   //the content object that is responsible for the insertion of a new annotation
   selectContentObject: function(){
	  if(this.startNode!=null){		
		  	  //console.log('Selection.selectContentObject this.startNode.parentNode.id' ,this.startNode.parentNode.id);
			  this.content = dijit.byId(this.startNode.parentNode.id);		
			  //console.log('Selection.selectContentObject', this.content.domNode, this.content);
	  }
	  else{
		  this.content =  this.annotationControl.content
		  }
  },
  
  setStartAndEndSeletionPosition: function(){
	  //console.log('Selection.setStartAndEndSeletionPositiont.addAnnotationPossible', this.addAnnotationPossible);
	  
	  if(this.addAnnotationPossible){
		  if(this.focus==this.anchor){
			  if(this.selection.anchorOffset>this.selection.focusOffset){
				  this.startPosition = this.selection.focusOffset;
				  this.endPosition = this.selection.anchorOffset;
			  }
			  else{
				  this.startPosition = this.selection.anchorOffset;
				  this.endPosition = this.selection.focusOffset;
			  }
		  }
		  else{
			  if(this.startNode==this.anchor){
				  this.startPosition = this.selection.anchorOffset;
				  this.endPosition = this.selection.focusOffset;
			  }	
			  else{
				  this.startPosition = this.selection.focusOffset;
				  this.endPosition = this.selection.anchorOffset;
			  }
		  }	  
	  }
	  else{
		  
		  this.startPosition = null;
		  this.endPosition = null; 			  
	  }
	  
  },
  
  setStartAndEndSeletionText: function(){
	  
	  //alert('setStartAndEndSeletionText'); 
	  
	  if(this.addAnnotationPossible){
		 
		  this.startText = this.startNode.data;
		  this.endText = this.endNode.data;
		
		  
	  }
	  else{
		  this.startText = "";
		  this.endText = "";  
	  }
  },
  

  
  cutText: function(){
	  
	  this.startTextBefore = this.startText.substr(0, this.startPosition);
	  this.endTextAfter = this.endText.substr(this.endPosition, this.endText.length-this.endPosition);
	 
	  if(this.startNode!=this.endNode){
		 
		 this.startTextAfter = this.startText.substr(this.startPosition, this.startText.length)
		 this.endTextBefore = this.endText.substr(0, this.endPosition);		 
	  }
	  else{
			 this.startTextAfter = this.startText.substr(this.startPosition, this.endPosition-this.startPosition)
			 this.endTextBefore = '';
	 }
  },
  
 ////////////////////////////////// GETTER ////////////////////////////////////////////////////////////
  
  
  //called in  Options
  getContent: function(){
	  return this.content;	 
  },
  
  //called in Toolbar
  getSelectedAnnotations: function(){	  
	  return this.selectedAnnotations;
  },
  
  //called in Content.insertAnnotation
  getSelectionStartIndex: function(){
	  return this.selectionStartIndex;
  },
  
  //called in Content.insertAnnotation
  getSelectionEndIndex: function(){
	  return this.selectionEndIndex;
  },
  
  
  
 
  
  
  
});
