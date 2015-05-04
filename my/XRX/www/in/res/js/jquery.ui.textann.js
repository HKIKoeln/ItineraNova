/*
 * jQuery UI Text Annotator
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {

var annEditorInstance;
var autosaving;

$.widget( "ui.textann", {

	version: "@VERSION",
	
	_create: function() {

		this._initTextarea();
		this._initForm();
		this._initToolbar();
		this._initAutoSave();
	},
	
	_ID: function() {
		
		var id = $(this.element[0]).attr("id");
		return id;
	},
	
	_initTextarea: function() {

		var textareas = this._getElementAnnTextarea();
		annEditorInstance = new Array(textareas.length);
		var textann = this;
		var form = this._getAnnForm();
		for(var i = 0; i < textareas.length; i++) {
			annEditorInstance[i] = CodeMirror.fromTextArea(textareas[i], {
				lineNumbers: true,
				onChange: function() {
					
					textann._savedStatus("status-autosaving");
					window.clearTimeout(autosaving);
					console.log("Clear Timeout");
					autosaving = setTimeout(function(){
						
						form.submit();
						textann._savedStatus("status-all-changes-saved");
						
					}, 5000);
				}
			});
		}
	},
	
	_initForm: function() { 
		
		var form = this._getAnnForm();
		var textann = this;
		form.submit(function(event) {
			
			event.preventDefault();

		    var register = form.find( 'input[name="register"]' ).val();
		    var act = form.find( 'input[name="act"]' ).val();
		    var mode = form.find( 'input[name="mode"]' ).val();
		    var transcription = "";
		    for(var i = 0; i < annEditorInstance.length; i++) {
		    	
		    	transcription += annEditorInstance[i].getValue();
		    	if(i != annEditorInstance.length - 1) transcription += "||||";
		    }
		    var url = form.attr( 'action' );
		
		    $.post( url, { register: register, act: act, mode: mode, transcription: transcription });
		    
		});
	},

	_initToolbar: function() {
		
		// save button
		var saveButton = $( "#save-button" );
		var form = this._getAnnForm();
		var textann = this;
		saveButton.click( function() {
			form.submit();
			textann._savedStatus("status-all-changes-saved");
		});
		
		// select box for font size
		var fontSizeButton = $( "#font-size-button" );
	    fontSizeButton.change(function() {
	      $( ".CodeMirror" ).css("font-size", fontSizeButton.val() + "px");
	      annEditorInstance[0].refresh();
	    });
	    
		// select box for special characters
	    var specialCharButton = $( "#special-char-button" );
	    specialCharButton.change(function() {
			annEditorInstance[0].replaceRange(specialCharButton.val(), annEditorInstance[0].getCursor(false));
			specialCharButton.val("");
	    });
	    
	    // syntax button
	    var syntaxButton = $( "#syntax-button" );
	    var syntaxHelpDialog = $( "#syntax-help" )
	    syntaxButton.click(function() {
	    	syntaxHelpDialog.toggle();
	    });
	    syntaxHelpDialog.draggable();
	},
	
	_initAutoSave: function() {
		
		var textann = this;
		var form = this._getAnnForm();
		// save every minute to keep the connection
		window.setInterval(function() {
			
			textann._savedStatus("status-autosaving");
			form.submit();
			textann._savedStatus("status-all-changes-saved");
			
		}, 60000);
	},
	
	_savedStatus: function(status) {
		
		$(".status-saved").each(function() {
			
			$(this).hide();
		});
		$("." + status).show();
	},
	
	_getElementAnnTextarea: function() {
		
		var textarea = $($(this.element[0])
			.find(".ui-textann-editor"))
			.toArray();
		return textarea;
	},
	
	_getAnnTextarea: function() {
		
		var textarea = $(this._getElementAnnTextarea());
		return textarea;
	},
	
	_getElementAnnForm: function() {
		
		var form = $(this.element[0])
			.find(".ui-textann-form")
			.toArray()[0];
		return form;
	},
	
	_getAnnForm: function() {
		
		var form = $(this._getElementAnnForm());
		return form;
	},
	
	_getElementAnnSubmit: function() {
		
		var submit = $(this.element[0])
			.find(".ui-textann-form")
			.find(".ui-textann-submit")
			.toArray()[0];
		return submit;
	},
	
	_getAnnSubmit: function() {
		
		var submit = $(this._getElementAnnSubmit());
		return submit;
	},
	
	_getElementsAnnData: function() {
		
		var data = $(this.element[0])
			.find(".ui-textann-data");
		return data;
	}
	
});

})( jQuery );
