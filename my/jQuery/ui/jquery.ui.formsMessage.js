/*
 * jQuery UI Forms Message
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {

var uiMainDivId						=	"forms-message";	
	
$.widget( "ui.formsMessage", $.ui.formsI18n, {

	options: {
		state: "",
		icon: "",
		message: ""
	},
	
	_create: function() {
		
		this.i18nCatalog = jQuery.parseJSON($('.xrx-forms-i18n-catalog').text());
		var self = this,
			state = self.options.state,
			icon = self.options.icon,
			message = self.options.message,
			
			messageDiv = $('<div></div>')
				.attr("id", uiMainDivId)
				.addClass("ui-state-" + state)
				.addClass("ui-corner-all"),
			
			messageIcon = $('<span></span>')
				.addClass("ui-icon")
				.addClass("ui-icon-" + icon)
				.css("float", "left")
				.css("margin-top", ".3em")
				.css("margin-right", ".3em"),
			
			messageText = $('<span></span>')
				.text(message);
		
		messageDiv.append(messageIcon).append(messageText);
		
		self.element.replaceWith(messageDiv);
	}
		
});
	
})( jQuery );