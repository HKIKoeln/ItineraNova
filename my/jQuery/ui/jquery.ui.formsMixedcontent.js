/*
 * jQuery UI Forms Mixed Content
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {
	
$.widget( "ui.formsMixedcontent", $.ui.formsI18n, {

	options: {
		charElementStart: "»",
		charElementEnd: "«"
	},
	
	/*
	 * Public Interface
	 */
	clear: function() {
		
		this.codemirror.clear()
	},
	
	/*
	 * Private Functions
	 */
	_create: function() {
		var self = this,
			dom = self.element[0],
			xPathRef = $(dom).attr("xrx:ref");
		
		$(dom).val(self._initMixedcontent(dom, 'xs:complexType'));
		
		self.codemirror = CodeMirror.fromTextArea(dom, 
			{ 
				mode: "text/visualxml", 
				lineWrapping: true,
				dragDrop: false,
				keyMap: "visualxml",
				onCursorActivity: function() { self.codemirror.matchElement(); },
				onChange: function(cm, change) { self.codemirror.contentChanged(cm, change); },
				onFocus: function() { 
					$(".forms-mixedcontent").each(function() {
						$(this).formsMixedcontent("clear");
					});
					$(self.codemirror.getScrollerElement()).addClass("xrx-forms-control-hover");
					self.codemirror.matchElement();
					self.codemirror.keepValue();
				}
		});
		
		$(self.codemirror.getInputField()).attr("xrx:ref", xPathRef);		
	},

	_initMixedcontent: function(control, contentType) {
		var self = this, result = "", xmlString = $('.xrx-forms-instance').text();
		var formsXPath = $(control).attr('xrx:ref'), xpathMatches = false, saxXPath = "";
		var contentHandler = new DefaultHandler();
        contentHandler.startElement = function(namespaceURI, localName, qName, atts) {
        	saxXPath += "/" + qName;
        	if(saxXPath == formsXPath) xpathMatches = true; 
        	if(xpathMatches == true && contentType == 'xs:complexType') result += self.options.charElementStart;
        };
        contentHandler.endElement = function(namespaceURI, localName, qName) {
        	if(xpathMatches == true && contentType == 'xs:complexType') result += self.options.charElementEnd; 
        	if(saxXPath == formsXPath) xpathMatches = false;
        	var length = saxXPath.length - "/".length - qName.length;
        	saxXPath = saxXPath.substring(0, length);
        };
        contentHandler.characters = function(ch, start, length) { 
        	if(xpathMatches == true) {
        		result += CodeMirror.splitLines(ch).join("");
        	}
        };
		var saxParser = XMLReaderFactory.createXMLReader();
		saxParser.setHandler(contentHandler);
		saxParser.parseString(xmlString);
		return result;
	}
	
});
	
})( jQuery );

