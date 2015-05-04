/*
 * XML Update facilities for XRX Forms
 * (based on jssaxparser.js)
 */
;(function() {
	
var TOKEN_ELEMENT_START = "»";
var TOKEN_ELEMENT_END = "«";
var regexElementToken = new RegExp("("+TOKEN_ELEMENT_START+"|"+TOKEN_ELEMENT_END+")");

var NODE_ELEMENT_START = "element-start";
var NODE_ELEMENT_END = "element-end";
var NODE_TEXT = "text";

var OP_INSERT_ATTRIBUTES = "insertAttributes";
var OP_DELETE_ATTRIBUTES = "deleteAttributes";
var OP_REPLACE_ATTRIBUTE_VALUE = "replaceAttributeValue";
var OP_INSERT_ELEMENT_POINTER = "insertElementPointer";
var OP_INSERT_ELEMENT_SELECTION = "insertElementSelection";
var OP_REPLACE_TEXT_NODE = "replaceTextNode";
var OP_INSERT_TEXT_NODE = "insertTextNode";
var OP_DELETE_ELEMENT_TAG = "deleteElementTag";

var autosave;
	
function formsInstance() {
	
	this.contentHandler = new DefaultHandler();
	this.saxParser = XMLReaderFactory.createXMLReader();
	this.saxParser.setHandler(this.contentHandler);
	
	/*
	 * private functions
	 */
	// convert an array of qNames into a XPath
	this.saxXPathString = function(array) { return "/" + array.join("/"); };
	// convert an array of numbers into a level id
	this.saxIdString = function(array) { return array.join("."); };
	
	// helper functions to clone XML nodes
	this.cloneStartElement = function(namespace, qName, attributes) { 
		var attributeString = "", i, j, attsArray, ns = qName.substring(":"), nsString = "";
		if(attributes != undefined) attsArray = attributes.attsArray;
		for(i in attsArray) { attributeString += " " + attsArray[i].qName + "=\"" + attsArray[i].value + "\""; };
		for(j in namespace) nsString += namespace.pop();
		return '<' + qName + nsString + attributeString + '>'; 
	};
	this.cloneEndElement = function(qName) {
		return '</' + qName + '>';
	};
	this.update = function(xmlString, formsRef, firstToken, lastToken, operation) {
		
		// left side of a selection or single cursor token
		var firstId = firstToken.state.context.id, 
			firstNodeType = firstToken.state.context.nodeType, 
			firstNumText = firstToken.state.context.numText;

		// right side of the selection if something is selected
		var lastId, lastNodeType, lastNumText;
		
		var xmlUpdate = this, // self reference
			result = ""; // XML-string to return
		
		var saxXPath = [], saxXPathString = "", previousSaxXPath, pathLength = 0, 
			xpathMatches = false, // true if the referenced element of a mixed content control is reached
			firstNodeMatch = false, // true if the left side of the selection is reached or a single cursor position
			lastNodeMatch = false; // true if the right side of a selection is reached
		
		var saxId = [], previousNodeType = "", numTextArray = []; // helper variables to calculate if XPath matches
		var namespace = []; // helper variable to copy namespaces into the XML result
		var somethingSelected; 
		
		//console.log("ID: " + firstId + " Node Type: " + firstNodeType + " Num Text: " + firstNumText);

		if(lastToken != null) {
			lastId = lastToken.state.context.id, 
			lastNodeType = lastToken.state.context.nodeType, 
			lastNumText = lastToken.state.context.numText;	
		}
		// ignorable whitespace
		this.contentHandler.ignorableWhitespace = function(ch, start, length) {
			result += ch;
		}		
		// prefix mapping
		this.contentHandler.startPrefixMapping = function(prefix, namespaceURI) {
			namespace.push(" xmlns:" + prefix + "=\"" + namespaceURI + "\"");
		}
		// start element
		this.contentHandler.startElement = function(namespaceURI, localName, qName, atts) {
			pathLength = saxXPath.length - formsRef.split("/").length + 2;
			// compose SAX XPath
			saxXPath.push(qName);
			//console.log("Start " + saxXPathString(saxXPath));
			// XPath matches?
			if(xmlUpdate.saxXPathString(saxXPath) == formsRef) xpathMatches = true;
			//console.log(xpathMatches);
			// compose SAX ID
			if(!xpathMatches) result += xmlUpdate.cloneStartElement(namespace, qName, atts);
			else {
		    	if(!saxId[pathLength] || saxId[pathLength] == 0) saxId[pathLength] = 1;
		    	else saxId[pathLength] = saxId[pathLength] + 1;
		    	//console.log("Start SAX ID " + saxId);
		    	if(firstId == xmlUpdate.saxIdString(saxId)) firstNodeMatch = true;
		    	if(lastId == xmlUpdate.saxIdString(saxId) && lastNodeType == NODE_ELEMENT_START) lastNodeMatch = true;
		    	
		    	switch(operation) {
		    	
		    	case OP_INSERT_ATTRIBUTES:
		    		if(firstNodeMatch == true && (firstNodeType == NODE_ELEMENT_START || firstNodeType == NODE_ELEMENT_END)) {
		    			for(var a = 0 in xmlUpdate.attributesToUpdate) 
		    				atts.attsArray.push(xmlUpdate.attributesToUpdate[a]);
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		} else result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;
		    		
		    	case OP_DELETE_ATTRIBUTES:
		    		if(firstNodeMatch == true && (firstNodeType == NODE_ELEMENT_START || firstNodeType == NODE_ELEMENT_END)) {
		    			for(var a1 = 0 in atts.attsArray) {
		    				for(var a2 in xmlUpdate.attributesToUpdate)
		    					if(xmlUpdate.attributesToUpdate[a2].qName == atts.attsArray[a1].qName) atts.attsArray.splice(a1, 1);
		    			}
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		} else result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;
		    		
		    	case OP_REPLACE_ATTRIBUTE_VALUE:
		    		if(firstNodeMatch == true && (firstNodeType == NODE_ELEMENT_START || firstNodeType == NODE_ELEMENT_END)) {
		    			for(var a1 = 0 in atts.attsArray) {
		    				if(xmlUpdate.attributesToUpdate[0].qName == atts.attsArray[a1].qName) atts.attsArray[a1].value = xmlUpdate.replaceValue;
		    			}
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		} else result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;
		    	
		    	case OP_INSERT_TEXT_NODE:
		    		if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_START) {
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    			result += xmlUpdate.textToUpdate;
		    		} else result += xmlUpdate.cloneStartElement(namespace, qName, atts);		    		
		    		break;
		    	
		    	case OP_DELETE_ELEMENT_TAG:
		    		if(firstNodeMatch == true && (firstNodeType == NODE_ELEMENT_START || NODE_ELEMENT_END)) {
		    			// delete
		    		} else result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;
		    	
		    	case OP_INSERT_ELEMENT_POINTER:
		    		if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_START) {
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert);	
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert);	    			
		    		} else result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;

		    	case OP_INSERT_ELEMENT_SELECTION:
		    		if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_START) {
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert); 			
		    		}
		    		else if(lastNodeMatch == true && lastNodeType == NODE_ELEMENT_START) {
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert); 
		    			result += xmlUpdate.cloneStartElement(namespace, qName, atts);			
		    		}
		    		else result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;
		    		
		    	default:
		    		result += xmlUpdate.cloneStartElement(namespace, qName, atts);
		    		break;
		    	}
		    	firstNodeMatch = false;
		    	lastNodeMatch = false;
		    	previousNodeType = NODE_ELEMENT_START;
			}
			namespace = [];
			//console.log(atts);
		}
		// end element
	    this.contentHandler.endElement = function(namespaceURI, localName, qName) {
			//console.log("End " + saxXPathString(saxXPath));
	    	//console.log(xpathMatches);
	    	// compose SAX ID
	    	if(!xpathMatches) result += xmlUpdate.cloneEndElement(qName);
	    	else {
	        	if(previousNodeType == NODE_ELEMENT_END) saxId.pop();
	        	//console.log("End SAX ID " + saxId);
	    		
	    		if(firstId == xmlUpdate.saxIdString(saxId)) firstNodeMatch = true;
	    		if(lastId == xmlUpdate.saxIdString(saxId)) lastNodeMatch = true;
	    		
	    		switch(operation) {
	    		
	    		case OP_INSERT_ELEMENT_POINTER:
		    		if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_END) {
		    			result += xmlUpdate.cloneEndElement(qName);
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert);	
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert);
		    		} else result += xmlUpdate.cloneEndElement(qName);
		    		break;

		    	case OP_INSERT_ELEMENT_SELECTION:
		    		if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_END) {
		    			result += xmlUpdate.cloneEndElement(qName);
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert);
		    		} 
		    		else if(lastNodeMatch == true && lastNodeType == NODE_ELEMENT_END) {
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert);
		    			result += xmlUpdate.cloneEndElement(qName);
		    		} 
		    		else result += xmlUpdate.cloneEndElement(qName);
		    		break;
		    	
	    		case OP_REPLACE_TEXT_NODE:
	    			if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_END) {
	    				result += xmlUpdate.cloneEndElement(qName);
	    				xmlUpdate.endElementFlag = true;
		    		} else result += xmlUpdate.cloneEndElement(qName);
	    			break;
		    	
	    		case OP_INSERT_TEXT_NODE:
	    			if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_END) {
	    				 result += xmlUpdate.cloneEndElement(qName);
	    				 result += xmlUpdate.textToUpdate;
		    		} else result += xmlUpdate.cloneEndElement(qName);
	    			break;
		    	
		    	case OP_DELETE_ELEMENT_TAG:
		    		if(firstNodeMatch == true && (firstNodeType == NODE_ELEMENT_START || NODE_ELEMENT_END)) {
		    			// delete
		    		} else result += xmlUpdate.cloneEndElement(qName);
		    		break;
		    		
		    	default:
		    		result += xmlUpdate.cloneEndElement(qName);
		    		break;
	    		}
	    		
	    		firstNodeMatch = false;
	    		lastNodeMatch = false;
	    		previousNodeType = NODE_ELEMENT_END;
	    	}
	    	
	    	if(xmlUpdate.saxXPathString(saxXPath) == formsRef) xpathMatches = false;
	    	saxXPath.pop();
	    };
		
	    // characters
	    this.contentHandler.characters = function(ch, start, length) { 
        	
	    	if(!xpathMatches) result += ch;
	    	else {
        		var textId = saxId.slice(0);
        		previousNodeType == NODE_ELEMENT_START ? textId : textId.pop();
        		//console.log("Text SAX ID " + textId + "'" + ch + "'");
        		!numTextArray[textId] ? numTextArray[textId] = 1 : numTextArray[textId] += 1;
        		//console.log("Num Text Node " + numTextArray[textId]);
        		
        		// left side of selection or single cursor position reached?
        		if(firstId == xmlUpdate.saxIdString(textId)) firstNodeMatch = true;
        		// right side of selection reached?
        		if(lastId == xmlUpdate.saxIdString(textId)) lastNodeMatch = true;
        		
		    	switch(operation) {
		    	
		    	case OP_INSERT_ELEMENT_POINTER:
		    		if(firstNodeMatch == true && firstNodeType == NODE_TEXT && firstNumText == numTextArray[textId]) {
		    			result += xmlUpdate.splittedText.leftPart;
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert);	
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert);
		    			result += xmlUpdate.splittedText.rightPart;
		    		}
		    		else result += ch;
		    		break;

		    	case OP_INSERT_ELEMENT_SELECTION:
		    		if(firstNodeMatch == true && firstNodeType == NODE_TEXT && firstNumText == numTextArray[textId] && xmlUpdate.onlyText == true
		    				&& lastNodeMatch == true && lastNodeType == NODE_TEXT && lastNumText == numTextArray[textId]) {
		    			result += xmlUpdate.firstSplittedText.leftPart;
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert);
		    			result += xmlUpdate.selection;
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert);
		    			result += xmlUpdate.lastSplittedText.rightPart;
		    		}
		    		else if(firstNodeMatch == true && firstNodeType == NODE_TEXT && firstNumText == numTextArray[textId]) {
		    			result += xmlUpdate.firstSplittedText.leftPart;
		    			result += xmlUpdate.cloneStartElement("", xmlUpdate.elementToInsert);
		    			result += xmlUpdate.firstSplittedText.rightPart;
		    		}
		    		else if(lastNodeMatch == true && lastNodeType == NODE_TEXT && lastNumText == numTextArray[textId]) {
		    			result += xmlUpdate.lastSplittedText.leftPart;
		    			result += xmlUpdate.cloneEndElement(xmlUpdate.elementToInsert);
		    			result += xmlUpdate.lastSplittedText.rightPart;
		    		}
		    		else result += ch;
		    		break;
		    	
		    	case OP_REPLACE_TEXT_NODE:
		    		if(xmlUpdate.endElementFlag == true) {
		    			result += xmlUpdate.textToUpdate;
		    			xmlUpdate.endElementFlag = false;
		    		}
		    		else if(firstNodeMatch == true && firstNodeType == NODE_TEXT && firstNumText == numTextArray[textId]) {
		    			result += xmlUpdate.textToUpdate;
		    		}
		    		else if(firstNodeMatch == true && firstNodeType == NODE_ELEMENT_START && numTextArray[textId] == 1) {
		    			result += xmlUpdate.textToUpdate;
		    		}
		    		else result += ch;
		    		break;
		    		
		    	default:
		    		result += ch;
		    		break;
		    	}
        		
        		firstNodeMatch = false;
        		lastNodeMatch = false;
        	}
	    	
	    };	
		
		this.saxParser.parseString(xmlString);
		//console.log(result);
		return result;
	};
	
	this.updateInstance = function(instance, xmlString) {
		$(instance).text(xmlString);
		clearTimeout(autosave);
		$("#autoSaveStatus").text("Saving ...");
		autosave = setTimeout( function(){
			$(document).xmleditor("save");
			$("#autoSaveStatus").text("All changes saved.");
		}, 3000);
	};
};

/*
 * public interface
 * insert attributes into a element node
 */
formsInstance.prototype.insertAttributes = function(instance, control, token, attributes) {

	this.attributesToUpdate = attributes;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_INSERT_ATTRIBUTES);
	this.updateInstance(instance, result)
};
/*
 * public interface
 * remove attributes from a element node
 */
formsInstance.prototype.deleteAttributes = function(instance, control, token, attributes) {
	
	this.attributesToUpdate = attributes;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_DELETE_ATTRIBUTES);
	this.updateInstance(instance, result)
}
/*
 * public interface
 * replace value of a attribute node
 */
formsInstance.prototype.replaceAttributeValue = function(instance, control, token, attribute, value) {
	
	this.attributesToUpdate = attribute;
	this.replaceValue = value;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_REPLACE_ATTRIBUTE_VALUE);
	this.updateInstance(instance, result)
}
/*
 * public interface
 * insert element, cursor pointer
 */
formsInstance.prototype.insertElementPointer = function(instance, control, token, splittedText, qName) {
	
	this.elementToInsert = qName; // element name to insert
	this.splittedText = splittedText;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_INSERT_ELEMENT_POINTER);
	this.updateInstance(instance, result)
}
/*
 * public interface
 * insert element, cursor selection
 */
formsInstance.prototype.insertElementSelection = function(instance, control, firstToken, lastToken, firstSplittedText, lastSplittedText, selection, qName) {
	
	this.elementToInsert = qName;
	this.firstSplittedText = firstSplittedText;
	this.lastSplittedText = lastSplittedText;
	this.onlyText = regexElementToken.test(selection) ? false : true;
	this.selection = selection;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), firstToken, lastToken, OP_INSERT_ELEMENT_SELECTION);
	this.updateInstance(instance, result)
}
/*
 * public interface
 * replace text node
 */
formsInstance.prototype.replaceTextNode = function(instance, control, token, text) {
	
	this.textToUpdate = text;
	this.endElementFlag = false;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_REPLACE_TEXT_NODE);
	this.updateInstance(instance, result)
}
/*
 * public interface
 * insert text node
 */
formsInstance.prototype.insertTextNode = function(instance, control, token, text) {
	
	this.textToUpdate = text;
	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_INSERT_TEXT_NODE);
	this.updateInstance(instance, result)
}
/*
 * public interface
 * delete element tag
 */
formsInstance.prototype.deleteElementTag = function(instance, control, token) {

	var result = this.update($(instance).text(), $(control).attr("xrx:ref"), token, null, OP_DELETE_ELEMENT_TAG);
	this.updateInstance(instance, result)
}
this.formsInstance = formsInstance;

})();