/*
 * jQuery UI Forms Mixed Content Attributes
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.draggable.js
 *   jquery.ui.droppable.js
 */
(function( $, undefined ) {

var uiMainDivId						=	"forms-mixedcontent-attributes";
var uiTagnameDivClass				=	"forms-mixedcontent-attributes-tagname";
var uiEditAttributesDivClass		=	"forms-mixedcontent-edit-attributes";
var uiEditAttributeDivClass			=	"forms-mixedcontent-edit-attribute";
var uiSuggestedAttributesDivClass	=	"forms-mixedcontent-suggested-attributes";
var uiSuggestedAttributeDivsClass	=	"forms-mixedcontent-suggested-attribute";
var uiDroppableAttributeDivClass	=	"forms-mixedcontent-attribute-droppable";

var uiFormsTableClass				=	"forms-table";
var uiFormsTableRowClass			=	"forms-table-row";
var uiFormsTableCellClass			=	"forms-table-cell";

$.widget( "ui.formsMixedcontentAttributes", $.ui.formsI18n, {
	
	options: {
		elementName:null,
		suggestedAttributes:null,
		editedAttributes:null,
		cm:null,
		token:null
	},
	
	_create: function() {
		
		this.i18nCatalog = jQuery.parseJSON($('.xrx-forms-i18n-catalog').text());
		var self = this,
		
			suggestedAttributes = self.options.suggestedAttributes,
			editedAttributes = self.options.editedAttributes,
			
			mainDiv = $('<div></div>')
				.attr("id", uiMainDivId),
			/*	
			tagnameDiv = $('<div>' + self.i18nTranslate(self.options.elementName, "xs:element") + '</div>')
				.addClass(uiTagnameDivClass),*/
				
			editAttributesDiv = $('<div></div>')
				.addClass(uiEditAttributesDivClass)
				.addClass(uiFormsTableClass),
			
			droppableAttributeDiv = $('<div>&#160;</div>')
				.addClass(uiDroppableAttributeDivClass),
				
			suggestedAttributesDiv = $('<div></div>')
				.addClass(uiSuggestedAttributesDivClass)
		
		for(var i = 0 in editedAttributes) 
			editAttributesDiv.append(self._newEditAttribute(editedAttributes[i].qName, self.i18nTranslate(editedAttributes[i].qName, "xs:attribute"), editedAttributes[i].value));
		
		self._attributeDroppable(droppableAttributeDiv);
		
		for(var i = 0 in suggestedAttributes) {
			var name = suggestedAttributes[i];
			var newDiv = $('<div>' + self.i18nTranslate(name, "xs:attribute") + '<div>')
							.addClass(uiSuggestedAttributeDivsClass)
							.attr("title", name);
			
			suggestedAttributesDiv.append(newDiv);
			self._suggestedAttributeDraggable(newDiv);
		}
		
		mainDiv
			//.append(tagnameDiv)
			.append(editAttributesDiv)
			.append(droppableAttributeDiv)
			.append(suggestedAttributesDiv);
		self.element.replaceWith(mainDiv);
			
		for(var i = 0 in editedAttributes) {
			$("div[title='" + editedAttributes[i].qName + "']", "#" + uiMainDivId).draggable("disable");
		}
	},
	
	_newEditAttribute: function(name, label, value) {
		
		var self = this,
			cm = self.options.cm,
			token = self.options.token,
			
			newEditAttribute = $('<div></div>')
				.addClass(uiFormsTableRowClass)
				.addClass(uiEditAttributeDivClass),
			newEditAttributeLabel = $('<div><span>' + label + '<span></div>')
				.addClass(uiFormsTableCellClass),
			newEditAttributeInput = $('<input></input>')
				.addClass(uiFormsTableCellClass)
				.attr("value", value)
				.attr("name", name),
			newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
				addClass(uiFormsTableCellClass);
		
		newEditAttribute.append(newEditAttributeLabel)
			.append(newEditAttributeInput)
			.append(newEditAttributeTrash);
			
		self._trashIconClickable(newEditAttributeTrash, newEditAttribute);
		
		newEditAttributeInput.keyup(function() {
			var instance = new formsInstance();
			var impl = new AttributesImpl();
			impl.addAttribute(null, name, name, undefined, "");
			
			instance.replaceAttributeValue($('.xrx-forms-instance'), cm.getInputField(), token, impl.attsArray, $(this).val());
		})
		
		return newEditAttribute;	
	},
	
	_trashIconClickable: function(trashIcon, editAttribute) {

		var self = this,
			cm = self.options.cm,
			token = self.options.token;
				
		trashIcon.click(function(event) {
			var name = $($(editAttribute).find("input")).attr("name");
			var instance = new formsInstance();
			var impl = new AttributesImpl();
			
			editAttribute.remove();
			$("div[title='" + name + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
			
			// update the instance
			// TODO: should be handled by a call-back function
			impl.addAttribute(null, name, name, undefined, "");
			instance.deleteAttributes($('.xrx-forms-instance'), cm.getInputField(), token, impl.attsArray);
		});		
	},
	
	_suggestedAttributeDraggable: function(suggestedAttribute) {
		
		var self = this;
		
		suggestedAttribute.draggable({
			containment: "." + uiMainDivId,
			revert: "invalid",
			cursor: "move",
			helper: "clone",
			start: function(event, ui) { 
				$("." + uiDroppableAttributeDivClass, "#" + uiMainDivId).addClass("edit-attributes-droppable-active"); 
				suggestedAttribute.addClass("suggested-attribute-draggable-disabled"); 
			},
			stop: function(event, ui) { 
				$("." + uiDroppableAttributeDivClass, "#" + uiMainDivId).removeClass("edit-attributes-droppable-active"); 
				suggestedAttribute.removeClass("suggested-attribute-draggable-disabled"); 
			}
		});		
	},
	
	_attributeDroppable: function(droppableAttribute) {
		
		var self = this,
			cm = self.options.cm,
			token = self.options.token;
		
		droppableAttribute.droppable({
			accept: "." + uiSuggestedAttributeDivsClass,
			drop: function(event, ui) {
				
				var draggable = ui.draggable, 
					qName = draggable.attr("title"), 
					label = draggable.text(), 
					editWidget = self._newEditAttribute(qName, label, "");
				var instance = new formsInstance();
				var impl = new AttributesImpl();
				impl.addAttribute(null, qName, qName, undefined, "");
				
				$("." + uiEditAttributesDivClass, "#" + uiMainDivId).append(editWidget);
				draggable.draggable("disable");

				// update the instance
				// TODO: should be handled by a call-back function
				instance.insertAttributes($('.xrx-forms-instance'), cm.getInputField(), token, impl.attsArray);
			}
		});
	},
	
	hide: function() {
		
		
	}

});
	
})( jQuery );