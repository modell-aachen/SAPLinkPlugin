/*
Copyright (C) 2012, Modell Aachen GmbH
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.plugins.add( 'qwikisaplink',
{
	requires : [ 'dialog', 'fakeobjects' ],
	lang : [ 'de', 'en' ],

	init : function( editor )
	{
		editor.addCommand( 'qwikisaplink', new CKEDITOR.dialogCommand( 'qwikisaplink' ) );
		editor.ui.addButton( 'QWikiSAPLink',
			{
				label : editor.lang.qwikisaplink.toolbar,
				command : 'qwikisaplink',
				icon : this.path + 'images/sap-sprite_sap_klein.png'
			});
		CKEDITOR.dialog.add( 'qwikisaplink', this.path + 'dialogs/qwikisaplink.js' );
		editor.addCss(
			'img.cke_saplink' +
			'{' +
				'background-image: url(' + CKEDITOR.getUrl( this.path + 'images/sap-sprite_sap_20.png' ) + ');' +
				'background-position: center center;' +
				'background-repeat: no-repeat;' +
				'border: 1px solid #a9a9a9;' +
				'width: 42px;' +
				'height: 20px;' +
			'}'
		);

		if ( editor.addMenuItems )
		{
			editor.addMenuGroup( 'group_saplink' );
			editor.addMenuItem(
					'qwikisaplink',
					{
						label : editor.lang.qwikisaplink.contextmenu,
						icon : this.path + "images/sap-sprite_sap_klein.png",
						command : 'qwikisaplink',
						group : 'group_saplink',
						order : 1
					}
			);
		}
		// Modac : contextmenu
		editor.contextMenu.addListener( function( element, selection )
		{
			if ( element && element.is( 'img' ) && element.getAttribute( 'data-cke-real-element-type' ) == 'saplink' )
				return { qwikisaplink : CKEDITOR.TRISTATE_OFF };
		});
	},
	afterInit : function( editor )
	{
		var dataProcessor = editor.dataProcessor,
			dataFilter = dataProcessor && dataProcessor.dataFilter;
		var sapRegex = new RegExp("^%SAPLINK{[^}]*}%$");

		if ( dataFilter )
		{
			dataFilter.addRules(
				{
					elements :
					{
						// Modac : Hier werden alle Spans gefiltert und nach SAPLINKS durchsucht
					    span : function( element )
						{
							// Modac : Due to lovely Internet Explorer
							var attr = '';
							attr = element.attributes["class"];

							// Modac : Alle spans mit WYSIWYG_PROTECED Attribut werden hier ausgelesen
							if (attr == "WYSIWYG_PROTECTED")
							{
								if(element.children.length != 1) return element;
								var value = element.children[ 0 ].value;
								value = value.replace(/\n/, '');
								if ( sapRegex.test(value) )
								{
									return editor.createFakeParserElement( element, 'cke_saplink', 'saplink');
								}
								return element;
							}
						}
					}
				},
				4 // This must be lower than qwiki's
			);
		}

		editor.on( 'doubleclick', function( evt )
		{
			var element = CKEDITOR.plugins.link.getSelectedLink( editor ) || evt.data.element;

			if ( !element.isReadOnly() )
			{
				if ( element && element.is( 'img' ) && element.getAttribute( 'data-cke-real-element-type' ) == 'saplink' )
				{
					evt.data.dialog = 'qwikisaplink';
					editor.getSelection().selectElement( element );
				}
			}
		});
	}
} );

