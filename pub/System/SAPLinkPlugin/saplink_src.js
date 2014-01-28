jQuery(function($) {
    $('span.SAPLink').livequery(function(){
        var $this = $(this);
        var SAPLink = document.SAPLink;
        if(!SAPLink) {
            if(console && console.log) console.log('No SAPLink object!');
            return;
        }
        var transactionReg = new RegExp("SAP Transaction: ([a-zA-Z0-9_]+) ");
        var match = transactionReg.exec( $this.text() );
        if(match) {
            var transaction = match[1];
            var display = '';
            if(SAPLink.display === 'transaction') {
                display = ' ' + transaction;
            }
            var img = '<div class="SAPLinkSymbol" title="'+SAPLink.txt_tra+transaction+'">'+display+'</div>';
            if(SAPLink.type == 'web') {
                var $a = $('<a href="'+SAPLink.nwurl + '?~TRANSACTION='+transaction+'">'+img+'</a>');
                $this.replaceWith($a);
            } else {
                var $img = $(img);
                $this.replaceWith($img);
                $img.click(function(){
                        if(SAPLink.type == 'sc') {
                                var webtopic = encodeURIComponent(foswiki.getPreference('WEB') + '.' + foswiki.getPreference('TOPIC'));
                                var url = foswiki.getPreference('SCRIPTURLPATH') + '/rest' + foswiki.getPreference('SCRIPTSUFFIX') +
                                    '/SAPLinkPlugin/getlink?webtopic=' + webtopic + ';transaction=' + transaction;
                                window.location.href = url;
                        } else {
                            if(console && console.log) console.log('Unknown mode: ' + SAPLink.type);
                        }
                });
            }
        } else {
            if(console && console.log) {
                console.log('Invalid transaction code: ' + $this.text());
            }
        }
    });
});
