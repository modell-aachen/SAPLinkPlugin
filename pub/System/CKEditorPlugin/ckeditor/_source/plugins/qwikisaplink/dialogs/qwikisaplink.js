/*
Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.dialog.add( 'qwikisaplink', function( editor )
{
	var config = editor.config,
		lang = editor.lang.qwikisaplink,
		transaction;

	function createLink() {
		var data = {};
		this.commitContent( data );

		var newElement = CKEDITOR.dom.element.createFromHtml( '<span class="SAPLink TMLhtml">SAP Transaction: ' + data.transaction + ' </span>' );
		newElement = editor.createFakeElement( newElement, 'cke_saplink', 'saplink', false );
		if(element) {
			newElement.replace( element );
		} else {
			editor.insertElement( newElement );
		}
		return true;
	}

	var allowedChars = '[a-zA-Z0-9_]';
	var onShow = function() {
		var data = {};
		element = editor.getSelection().getSelectedElement();
		data.transaction = "";
		var getReal = editor.restoreRealElement(element);
		var regex = new RegExp("SAP Transaction: ("+allowedChars+"+) ");
		var html = getReal.getHtml();
		var match = regex.exec( html );
		if(match && match.length > 1) {
			data.transaction = match[1];
		}

		this.setupContent( data );
	};

	return {
		title : lang.title,
		minWidth : 270,
		minHeight : 120,
		contents : [
			{
				id : 'sapshortcut',
				label : lang.shortcut,
				elements: [
					{
						type : 'text',
						id : 'transaction',
						label : lang.transaction,
						setup : function(data) {
							this.setValue(data.transaction);
						},
						commit : function( data ) {
							data.transaction = this.getValue().toUpperCase();
						},
						validate : function( data ) {
							var value = this.getValue();
							var l = value.length;
							var errors;
							var validRegex = new RegExp("^"+allowedChars+"+$");
							if(!validRegex.test(value)) {
								errors = lang.invalidTransaction;
							}
							if(l == 0 ) {
								errors = lang.emptyTransaction;
							}
							return errors;
						},
						required : true
					}
				]
			}
		],
		onOk : createLink,
		onShow : onShow,
		buttons : [ CKEDITOR.dialog.okButton, CKEDITOR.dialog.cancelButton ]
	};
} );
