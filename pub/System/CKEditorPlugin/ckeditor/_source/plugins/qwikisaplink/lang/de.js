/*
Copyright (c) 2012, Modell Aachen, http://modell-aachen.de/

Kurzreferenz Umlaut-Codes:
ae \u00E4      AE \u00C4
oe \u00F6      OE \u00D6
ue \u00FC      UE \u00DC
ss \u00DF
*/

CKEDITOR.plugins.setLang( 'qwikisaplink', 'de',
{
	qwikisaplink :
	{
		toolbar: 'SAP-Link einf\u00FCgen/bearbeiten',
		title: 'SAP-Link ausw\u00E4hlen',
		contextmenu: 'SAP-Link Eigenschaften',
		options: 'SAP-Link Eigenschaften',
		transaction: 'Transaktion',
		shortcut: 'SAP-Shortcut',
		emptyTransaction: 'Bitte Transaktionsnummer angeben.',
		invalidTransaction: 'Die Transaktionsnummer darf nur aus Buchstaben (A-Z), Ziffern (0-9) und Unterstrichen (_) bestehen.'
	}
});
