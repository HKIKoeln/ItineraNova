define("xrxa/util", ["dojo", "dijit"], function(dojo, dijit) {


	

//TO gleiche Funktionen von HRXElement und HRXStartTag gemeinsam auslagen
xrxa.getLocalNodeName = function(node)
{	
	nodeName = node.nodeName.toLowerCase();
	splittedNodeName = nodeName.split(":");
  //TODO: Wenn kein NS expliziet angegeben
	return splittedNodeName[1];
};

xrxa.getNodeName = function(node)
{	
	nodeName = node.nodeName; //.toLowerCase();
  //TODO: Wenn kein NS expliziet angegeben
	return nodeName;
};

xrxa.getLocalNodeNameByName = function(name)
{	
	nodeName = name.toLowerCase();
	splittedNodeName = nodeName.split(":");
  //TODO: Wenn kein NS expliziet angegeben
	return splittedNodeName[1];
};

xrxa.getNamespace = function(node)
{	
	  
	  nodeName = node.nodeName.toLowerCase(); 
	 
	  
	  splittedNodeName = nodeName.split(":");
	  //TODO: Wenn kein NS expliziet angegeben
	  return splittedNodeName[0];
	  
};

xrxa.getNamespaceByName = function(name)
{	
	  
	  nodeName = name.toLowerCase(); 	  
	  splittedNodeName = nodeName.split(":");
	  //TODO: Wenn kein NS expliziet angegeben
	  return splittedNodeName[0];
	  
};

////////////////////////////////////////////////////////////////////////////

xrxa.getPrefix2 = function(name)
{	 
	//if(name.contains(":")){
	splittedNodeName = name.split(":");
	return splittedNodeName[0];
	/*}
	else
		return null;*/
};

xrxa.getLocalName2 = function(name)
{	 
	//if(name.contains(":")){
		splittedNodeName = name.split(":");
		return splittedNodeName[1];
	/*}
	else
		return name;*/
};





/////////////////////////////////////////////////////////////////////////////////////////////

xrxa.getName = function(path)
{	
	splittedPath = nodeName.split("/");
	return splittedPath[splittedPath.length]
};

xrxa.getLocalName = function(path)
{	
	splittedPath = nodeName.split("/");
	return splittedPath[splittedPath.length]
};

xrxa.getPrefix = function(path)
{	
	splittedPath = nodeName.split("/");
	return splittedPath[splittedPath.length]
};

return xrxa;
});
