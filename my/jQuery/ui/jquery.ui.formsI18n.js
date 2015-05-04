/*
 * jQuery UI Forms
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {
	
$.widget( "ui.formsI18n", {
	
	_create: function() {
		
		this.i18nCatalog = jQuery.parseJSON($('.xrx-forms-i18n-catalog').text());
	},
	
	i18nTranslate: function(key, type) {
		var optimizedKey = "", translated;
		switch(type) {
		case "xs:attribute":
			optimizedKey = "cei_" + key.replace(":", "_");
			break;
		case "xs:element":
			optimizedKey = key.replace(":", "_");
			break;
		default:
			optimizedKey = key;
			break;
		}
		translated = this.i18nCatalog[optimizedKey] ? this.i18nCatalog[optimizedKey] : key;
		return translated;
	} 
		
});
	
})( jQuery );