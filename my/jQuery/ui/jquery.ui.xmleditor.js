/*
 * jQuery UI XML Editor
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.tabs.js
 */
(function( $, undefined ) {

var serviceMyCollectionSave             =        "tag:www.monasterium.net,2011:/mom/service/my-collection-save";

$.widget( "ui.xmleditor", {

	options: {
		requestRoot: ""
	},
	
	_create: function() {
		
        jQuery(document).forms();
		$("#ui-imageann").imageann();
		$("#dedit-my-collection-context").tabs();
	},
	
	save: function() {
		
		var self = this;
		console.log(self.options.requestRoot + "service/?atomid=" + serviceMyCollectionSave);
		$.ajax({
			url: self.options.requestRoot + "service/?atomid=" + serviceMyCollectionSave,
			type: "POST",
			contentType: "application/xml",
			data: $(".xrx-forms-instance").text()
		});
	}
	
});
	
})( jQuery );