/*
 * jQuery UI Image Annotator
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.mousewheel.js
 */
(function( $, undefined ) {

$.widget( "ui.imageann", {
	
	version: "@VERSION",
	
	_create: function() {
		
		this._initMousewheel();
		this._initDraggable();
		this._initImageSelect();
	},

	_initDraggable: function() {
		
        this.uiSelf().find( "div" ).draggable();
		var firstImage = 
			$(this.uiSelf().find( "div" )).find( "img" );
		firstImage.css("display", "inline");
	},
	
	_initMousewheel: function() {
		
		var scale = 1;
		this.uiSelf().mousewheel(function(e, delta)
		{
		    if (delta > 0)
		    {
		        scale += 0.05;
		    }
		    else
		    {
		        scale -= 0.05;
		    }
		    scale = scale < 0.2 ? 0.2 : (scale > 40 ? 40 : scale);
		
		    var x = e.pageX - $(this).offset().left;
		    var y = e.pageY - $(this).offset().top;
		
		    $(this).find( "div" ).css("-moz-transform", "scale(" + scale + ")")
		        .css("-o-transform", "scale(" + scale + ")")
		        .css("-webkit-transform", "scale(" + scale + ")")
		        .css("-moz-transform-origin", x + "px " + y + "px")
		        .css("-o-transform-origin", x + "px " + y + "px")
		        .css("-webkit-transform-origin", x + "px " + y + "px");
		
		    return false;
		});
	},
	
	uiSelf: function() {
		
		return $( "#ui-imageann" )
	},
	
	uiImageselect: function() {
		
		return $( "#ui-imageselect" )
	},
	
	_initImageSelect: function() {
		
		this.uiImageselect().selectable({
			stop: function() {
				var result = $( "#img" );
				$( ".ui-selected", this ).each(function() {
					var index = $( "#ui-imageselect li" ).index(this);
					var url = $($( "#ui-imageselect li" )[index]).attr("title");
					result.attr( "src", url );
				});
			}
		});
	}
});

})( jQuery );