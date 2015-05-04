/*
 * jQuery UI Forms Mixed Content Tag-name
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {

var uiMainDivId						=	"forms-mixedcontent-tagname";	
	
$.widget( "ui.formsMixedcontentTagname", $.ui.formsI18n, {

	options: {
		qName: null
	},
	
	_create: function() {
		
		this.i18nCatalog = jQuery.parseJSON($('.xrx-forms-i18n-catalog').text());
		var self = this,
			name = self.options.qName,
			
			tagnameDiv = $('<div></div>')
				.attr("id", uiMainDivId)
				.text(self.i18nTranslate(name, "xs:element"));
		
		self.element.replaceWith(tagnameDiv);
	}
		
});
	
})( jQuery );