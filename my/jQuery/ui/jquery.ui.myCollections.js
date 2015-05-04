 /* jQuery UI MOM myCollections environment
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.button.js
 *   jquery.ui.dialog.js
 */
(function( $, undefined ) {
/*
 * IDs
 */
var uiMyCollectionsTreeDivId            =        "dmy-collections-tree";	
var uiMyCollectionItemsDivId            =        "dmy-collection-items";	
var uiMyCollectionItemsToolbarDivId     =        "dmy-collection-items-toolbar";
var uiMyCollectionBookmarksButton       =        "dmy-collection-bookmarks-button";
var uiMyCollectionsButtonId             =        "dmy-collections-button";
/*
 * Classes
 */
var uiMyCollectionsTreeItemClass        =        "my-collections-tree-item";
var uiMyCollectionsTreeItemClassSelected =       "selected-collections-tree-item";
var uiMyCollectionItemClass             =        "my-collection-item";
var uiMyCollectionItemClassHover        =        "my-collection-item-hover";
var uiMyCollectionItemClassDragstart    =        "my-collection-item-dragstart";
var uiMyCollectionItemDraggableHelperClass =     "my-collection-item-draggable-helper";
/*
 * Services
 */
var serviceMyCollectionsTree            =        "tag:www.monasterium.net,2011:/mom/service/my-collections-tree";
var serviceMyCollectionItems            =        "tag:www.monasterium.net,2011:/mom/service/my-collection-items";
var serviceMyCollectionCharterNew       =        "tag:www.monasterium.net,2011:/mom/service/my-collection-charter-new";
var serviceMyCollectionCharterDelete    =        "tag:www.monasterium.net,2011:/mom/service/my-collection-charter-delete";
var serviceMyCollectionCharterNewVersion =       "tag:www.monasterium.net,2011:/mom/service/my-collection-charter-new-version";
var serviceMyCollectionDelete           =        "tag:www.monasterium.net,2011:/mom/service/my-collection-delete";
var serviceMyCollectionBookmarks        =        "tag:www.monasterium.net,2011:/mom/service/my-collection-bookmarks";
	        	  
$.widget( "ui.myCollections", {

	options: {
		requestRoot: ""
	},
	
	_create: function() {
		
		this.selectedItemCounter = 0;
		
		this._myCollectionsInit();
		this._myCollectionBookmarksInit();
	},

	/*
	 * Shared Functions
	 */
	_myCollectionTreeItem: function(item, clickFunction, collectionContextAtomid) {
		
		var self = this, hoverClass = "my-collection-tree-item-hover";
		$(item).addClass(uiMyCollectionsTreeItemClass);
		$(item).hover( 
			function() { $(this).addClass(hoverClass); },
			function() { $(this).removeClass(hoverClass); }
		);
		if(clickFunction != undefined){ 
			$(item).click( function() {
				$("." + uiMyCollectionsTreeItemClass, "#dmy-collection-left-menu").removeClass(uiMyCollectionsTreeItemClassSelected);
				$(item).addClass(uiMyCollectionsTreeItemClassSelected);
				clickFunction(self, collectionContextAtomid);
			});
		}
	},	
	_serviceUrl: function(atomid) {
		return this.options.requestRoot + "service/?atomid=" + atomid;
	},
	
	/*
	 * My Collection Items
	 */
	_myCharterNewButton: function(atomid) {
		
		var self = this,
		
		    button = $('<button>Create Charter</button>')
		    	.button({
		    		icons: {
		    			primary: "ui-icon-gear"
		    		}
		    	})
		    	.click( function() {
					$.ajax({ 
						url: self._serviceUrl(serviceMyCollectionCharterNew), 
						type: "POST",
						data: { mycollection: atomid },
					    success: function() { self._myCollectionItems(self, atomid); }
					})
		    	});
		return button;
	},
	
	_myChartersDelete: function(button) {
		
		var self = this, inputs = $("input", "#" + uiMyCollectionItemsDivId),
			xml = '<objectids xmlns="">', checkedItemDivs = [];
		$.each(inputs, function(index, input) {
			if($(input).is(":checked")) {
				xml += '<objectid>';
				xml += $(input).parent().parent().attr("id");
				xml += '</objectid>';
				checkedItemDivs.push($(input).parent().parent());
			}
		});
		xml += '</objectids>';
		$("#forms-message").formsMessage({ 
			state: "highlight",
			icon: "info",
			message: "Deleteing Items ..."
		});					
		$.ajax({
			url: self._serviceUrl(serviceMyCollectionCharterDelete),
			contentType: "application/xml",
			type: "POST",
			data: xml,
			complete: function(data, textStatus, jqXHR) {
				button.hide();
				for(var i in checkedItemDivs) {
					$(checkedItemDivs[i]).effect("pulsate", {}, 500, function() { $(this).remove() });
				}
				$("#forms-message").formsMessage({ 
					state: "highlight",
					icon: "info",
					message: "Items successfully deleted."
				});
				$("#forms-message").delay(2000).slideUp(1000);							
			}
		});		
	},
	
	_myChartersDeleteButton: function() {
		
		var self = this,
		
			button = $('<button>Delete selected Charter(s)</button>')
				.button({
					icons: {
						primary: "ui-icon-gear"
					}
				})
				.click( function() {
					$("#dmy-collection-items-remove-dialog").dialog({
						resizable: false,
						width: 300,
						modal: true,
						buttons: {
							"Delete all items": function() {
								self._myChartersDelete(button);
								$(this).dialog("close");
							},
							Cancel: function() {
								$(this).dialog("close");
							}
						}
					});					
				});
		return button;
	},
	
	_myCollectionItems: function(self, atomid) {
		
		$("#forms-message").formsMessage({ 
			state: "highlight",
			icon: "info",
			message: "Loading Items ..."
		});		
			// initial DIV
		var myCollectionItemsDiv = $("#" + uiMyCollectionItemsDivId),
			requestRoot = self.options.requestRoot,
			
			// create buttons
			toolbarDiv = $('<div></div>')
			    .attr("id", uiMyCollectionItemsToolbarDivId),
			charterNewButton = self._myCharterNewButton(atomid),
			chartersDeleteButton = self._myChartersDeleteButton().hide(),
			
			// compose preface DIV
		    itemsDiv = $('<div></div>')
		        .attr("id", uiMyCollectionItemsDivId)
		        .attr("requestRoot", requestRoot),
		    itemDivPreface = $('<div></div>')
		    	.addClass(uiMyCollectionItemClass)
		    	.hover(
		            function(){ $(this).addClass(uiMyCollectionItemClassHover); },
		            function(){ $(this).removeClass(uiMyCollectionItemClassHover); }
		    	),
		    itemLinkPreface = $('<a></a>')
		        .attr("href", requestRoot + "preface/" + atomid + "/edit")
		        .attr("target", "_blank")
		        .text("Edit Collection Information"),
		
			// compose table
		    table = $('<div></div>')
		    	.addClass("forms-table"),
			tableHeader = $('<div></div>')
				.addClass("forms-table-row"),
			tableHeaderSelectAll = $('<div></div>')
				.addClass("forms-table-cell")
				.text("     "),
			tableHeaderTitle = $('<div></div>')
				.addClass("forms-table-cell")
				.text("Title"),
			tableHeaderVersionOf = $('<div></div>')
				.addClass("forms-table-cell")
				.text("Version of");
				
		// insert buttons
		toolbarDiv.append(charterNewButton)
			.append(chartersDeleteButton);
		// insert preface DIV
		itemDivPreface.append(itemLinkPreface);
		// compose table header
		tableHeader.append(tableHeaderSelectAll).append(tableHeaderTitle).append(tableHeaderVersionOf);
		table.append(tableHeader);
		// insert all into items DIV
		itemsDiv.append(toolbarDiv)
		    //.append(itemDivPreface)
		    .append(table);
		
		// compose DIVs for charters
		$.ajax({
			url: self._serviceUrl(serviceMyCollectionItems),
			dataType: 'json',
			data: { mycollection: atomid },
			success: function(data, textStatus, jqXHR) { 
				var length = 0;
				$.each(data, function(key, value) { 
					var charterTitle = value["title"],
						versionOfLink = value["versionOfLink"],
						versionOfTitle = value["versionOfTitle"],
					    itemDivCharter = $('<div></div>')
					    	.addClass("forms-table-row")
					    	.attr("id", key)
					    	.hover(
					            function(){ $(this).addClass(uiMyCollectionItemClassHover); },
					            function(){ $(this).removeClass(uiMyCollectionItemClassHover); }
					    	),
					    itemSelectCharter = $('<div></div>')
					    	.addClass("forms-table-cell")
					    	.append($('<input type="checkbox"/>')
						    	.change( function() {
						    		if($(this).is(":checked")) self.selectedItemCounter += 1;
						    		else self.selectedItemCounter -= 1;
						    		if(self.selectedItemCounter > 0) chartersDeleteButton.show();
						    		else chartersDeleteButton.hide();
						    	})
					    	),
					    itemLinkCharter = $('<div></div>')
					    	.addClass("forms-table-cell")
					    	.append($('<a></a>')
						        .attr("href", requestRoot + "charter/" + key + "/edit")
						        .attr("target", "_blank")
							    .text(charterTitle)
							),
						itemLinkVersionOf = $('<div></div>')
							.addClass("forms-table-cell")
							.append($('<a></a>')
								.attr("href", versionOfLink)
								.attr("target", "_blank")
								.text(versionOfTitle)
							);
					itemDivCharter.append(itemSelectCharter)
					    .append(itemLinkCharter)
					    .append(itemLinkVersionOf);
					if(key != "charter") {
						table.append(itemDivCharter);
						itemsDiv.append(table);
						length += 1; 
					}
				});	
				$("#forms-message").formsMessage({ 
					state: "highlight",
					icon: "info",
					message: "Loading Items (" + length + ") ..."
				});
				$("#forms-message").delay(2000).slideUp(1000);
			}
		});
		
		// replace the initial DIV
		myCollectionItemsDiv.replaceWith(itemsDiv);	
	},
	
	_myCollectionsTreeSelectItem: function(atomid) {
		
		var self = this,
		    treeItems = $("." + uiMyCollectionsTreeItemClass, "#" + uiMyCollectionsTreeDivId);
		$.each(treeItems, function(index) {
			var item = treeItems[index];
			self._myCollectionTreeItem(item);
		});
	},
	
	/*
	 * Bookmarks
	 */
	_myCollectionBookmarksInit: function() {
		
		this._myCollectionBookmarksButton();
	},
	
	_myCollectionBookmarksButton: function() {
		
		var self = this;
		self._myCollectionTreeItem($("#" + uiMyCollectionBookmarksButton), self._myCollectionBookmarksClick, null);
	},
	
	_myCollectionBookmarksClick: function(self, atomid) {
		
		 var itemsDiv = $('<div></div>')
		        .attr("id", uiMyCollectionItemsDivId)
		        .attr("requestRoot", self.options.requestRoot),
		    infoDiv = $('<div></div>')
		    	.html("Drag and Drop a Bookmark into one of your Collections to start a new Version of this Charter.<br/><br/>");
		itemsDiv.append(infoDiv);
		$("#forms-message").formsMessage({ 
			state: "highlight",
			icon: "info",
			message: "Loading Bookmarks ..."
		});
		$.ajax({
			url: self._serviceUrl(serviceMyCollectionBookmarks),
			dataType: 'json',
			success: function(data, textStatus, jqXHR) {
				var length = 0;
				$.each(data, function(key, value) {
					length += 1;
					var title = value["title"];
					var link = value["link"];
					var bookmarkDiv = $('<div></div>')
						.attr("title", key)
						.addClass(uiMyCollectionItemClass)
						.hover(
							function() { $(this).addClass(uiMyCollectionItemClassHover); },
							function() { $(this).removeClass(uiMyCollectionItemClassHover); }
						)
						.draggable({
							revert: "invalid",
							cursor: "pointer",
							helper: function() { 
								var div = $('<div></div>')
									.addClass(uiMyCollectionItemDraggableHelperClass)
									.addClass("ui-corner-all")
									.html("<span>Start a new version of</span><br/><span>'" + title + "'</span>");
								return div; 
							},
							handle: ".ui-icon",
							start: function(event, ui) { 
								 $(this).addClass(uiMyCollectionItemClassDragstart);
							},
							stop: function(event, ui) { 
								 $(this).removeClass(uiMyCollectionItemClassDragstart);
							}							
						});
					var arrowIconSpan = $('<span></span>')
						.addClass("ui-icon ui-icon-arrow-4-diag")
						.css("float", "left").css("margin-right", "1%").css("margin-top", "3px").css("cursor", "pointer");
					var titleSpan = $('<a></a>').text(title)
						.attr("href", link).attr("target", "_blank");
					bookmarkDiv.append(arrowIconSpan).append(titleSpan);
					itemsDiv.append(bookmarkDiv);
				});		
				$("#forms-message").formsMessage({ 
					state: "highlight",
					icon: "info",
					message: "Loading Bookmarks (" + length + ") ..."
				});
				$("#forms-message").delay(2000).slideUp(1000);		
			}
		});
		$("#" + uiMyCollectionItemsDivId).replaceWith(itemsDiv);
	},
	
	/*
	 * Collection Tree
	 */
	_myCollectionsInit: function() {
		
		this._myCollectionsButton();
		this._myCollectionsTree();
		this._myCollectionNewDialog();
		this._myCollectionNewButton();
	},
	
	_myCollections: function() {
		
	},
	
	_myCollectionsButton: function() {
		
		var self = this;
		self._myCollectionTreeItem($("#" + uiMyCollectionsButtonId), self._myCollections);	
	},
	
	_myCollectionsTree: function() {
		
		var self = this,
	    	treeItems;
	    var collectionTreeDiv = $('<div></div>')
	    	.attr("id", uiMyCollectionsTreeDivId);
		$("#forms-message").formsMessage({ 
			state: "highlight",
			icon: "info",
			message: "Loading Collections ..."
		});
		$.ajax({
			url: self._serviceUrl(serviceMyCollectionsTree),
			dataType: 'json',
			success: function(data, textStatus, jqXHR) {
				var length = 0;
				$.each(data, function(key, value) { 
					var title = value["title"];
					var collectionDiv = $('<div></div>')
						.text(title)
						.attr("title", key)
						.addClass(uiMyCollectionsTreeItemClass)
						.droppable({
							hoverClass: "ui-state-hover",
							drop: function(event, ui) {
								var draggable = ui.draggable,
									charterAtomid = draggable.attr("title"),
									collectionObjectid = key;
								$.ajax({
									url: self._serviceUrl(serviceMyCollectionCharterNewVersion),
									type: "POST",
									data: { charteratomid: charterAtomid, collectionobjectid: collectionObjectid },
									success: function() { 
										$("#forms-message").formsMessage({ 
											state: "highlight",
											icon: "info",
											message: "A new version was successfully created."
										});
										$("#forms-message").delay(2000).slideUp(1000);
									}
								});
							}
						});
					self._myCollectionTreeItem(collectionDiv, self._myCollectionItems, key);
					collectionTreeDiv.append(collectionDiv);
					length += 1;
					$("#forms-message").formsMessage({ 
						state: "highlight",
						icon: "info",
						message: "Loading Collections (" + length + ") ..."
					});
					$("#forms-message").delay(2000).slideUp(1000);
				});				
			}
		});
		$("#" + uiMyCollectionsTreeDivId).replaceWith(collectionTreeDiv);
	},
	
	_myCollectionNewButton: function() {
		
		$("#dmy-collection-new-button")
			.button()
			.click( function() {
				$("#dmy-collection-new-dialog").dialog("open");
			});
	},
	
	_myCollectionNewDialog: function() {
		
		var self = this,
			newCollectionDialog = $("#dmy-collection-new-dialog"),
			form = $("#fmy-collection-new-dialog"),
			action = form.attr("action");
		
		form.submit( function(event){
			event.preventDefault();
		});
		
		newCollectionDialog.dialog({
			autoOpen: false,
			modal: true,
			width: 500
		});
		
		var collectionNewSuccess = function() {
			newCollectionDialog.dialog("close");
			self._myCollectionsTree();
		};
		var collectionNewError = function(xhr, ajaxOptions, thrownError) {
			console.log(xhr);
			console.log(thrownError);
		};
		
		$(".ok-button", "#dmy-collection-new-dialog")
			.button()
			.click( function() {
				var title = form.find( 'input[name="title"]' ).val();
				$.ajax({ 
					url:action, 
					type: "POST",
					data: { title:title },
					success: collectionNewSuccess,
					error: collectionNewError
				});
			});
	}
		
});
	
})( jQuery );