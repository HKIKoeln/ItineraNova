/*
 * jQuery UI Transcription Editor
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {
	
$.widget( "ui.transcriptionEditor", {
	
	version: "@VERSION",
	
	_create: function() {
		
		this._optimizeView();
		this._initWindowResize();
	},
	
	_optimizeView: function() {
		
		var headerHeight = this.header().outerHeight();
		var toolbarHeight = this.toolbar().outerHeight();
		var windowHeight = $(window).height();
		var iaOptimizedHeight = (windowHeight - headerHeight - toolbarHeight) * 40 / 100;
		this.imageann().css("height", iaOptimizedHeight + "px");
		var taOptimizedHeight = ((windowHeight - headerHeight - toolbarHeight) * 60 / 100) - 70;
		this.textann().css("height", taOptimizedHeight + "px");
		
		/*
		console.log("Window height: " + $(window).height());
		console.log("uiHeader height: " + headerHeight);
		console.log("uiTextann height: " + taOptimizedHeight);
		console.log("uiImageann height: " + iaOptimizedHeight);
		*/
	},
	
	_initWindowResize: function() {
		
		var transcriptionEditor = this;
		var resizeTimer = null;
		$(window).bind('resize', function() { 
		    if (resizeTimer) clearTimeout(resizeTimer); 
		    resizeTimer = setTimeout(transcriptionEditor._optimizeView(), 100);
		});
	},
	
	header: function() {
		
		return $(this.element[0]).find("#ui-transcriptionEditor-header");
	},
	
	toolbar: function() {
		
		return $(this.element[0]).find("#ui-transcriptionEditor-toolbar");
	},
	
	textann: function() {
		
		return $(this.element[0]).find("#ui-transcriptionEditor-textann");
	},
	
	imageann: function() {
		
		return $(this.element[0]).find("#ui-transcriptionEditor-imageann");
	}

});
	
})( jQuery );
