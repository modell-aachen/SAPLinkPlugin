# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html


package Foswiki::Plugins::SAPLinkPlugin;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

our $VERSION = '$Rev$';

our $RELEASE = '0.0.2';

our $SHORTDESCRIPTION = 'Create links to SAP-transactions.';

our $NO_PREFS_IN_TOPIC = 1;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerTagHandler( 'SAPLINK', \&_SAPLINK );

    Foswiki::Func::registerRESTHandler( 'getlink', \&restGetLink );

    # Plugin correctly initialized
    return 1;
}

sub _SAPLINK {
    my($session, $params, $topic, $web, $topicObject) = @_;

    my $transaction = $params->{_DEFAULT};
    return '' unless $transaction;

    my $image = '<img src="%PUBURLPATH%/%SYSTEMWEB%/SAPLinkPlugin/sap-sprite_sap_20.png" title="%MAKETEXT{"Transaction: [_1]" args="'.$transaction.'"}%" />';
    if($Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkMethod} eq 'web') {
        my $server = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkerver} || '';
        my $path = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkPath} || ''; # XXX error when empty
        return "[[http://$server/$path?~TRANSACTION=$transaction][$image]]";
    } elsif ($Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkMethod} eq 'sap-shortcut') {
        return "[[%SCRIPTURL{\"rest\"}%/SAPLinkPlugin/getlink?transaction=$transaction][$image]]";
    }
    return '';
}

sub restGetLink {
    my ( $session, $subject, $verb, $response ) = @_;

    my $wd = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkWorkingDir} || 'C:\Documents and Settings\%USERNAME%\My Documents\SAP';
    $wd = Foswiki::Func::expandCommonVariables($wd);
    my $username = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkUserName} || '%WIKINAME%';
    $username = Foswiki::Func::expandCommonVariables($username);
    my $sysname = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkSystemName} || ''; # XXX Error when empty
    my $sysdesc = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkSystemDesc} || ''; # XXX Error when empty
    my $lang = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkLanguage} || 'de';
    my $client = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkUserClient};
    if($client) {
        $client = "\nClient=$client";
    } else {
        $client = '';
    }

    my $query = $session->{request};
    my $transaction = $query->{param}->{transaction}[0] || die; # XXX
    my $title = $query->{param}->{title};
    $title = @$title[0] if $title;
    $title = 'SAP-Link' unless $title;
    my $reuse = $query->{param}->{reuse};
    if ($reuse) {
        $reuse = @$reuse[0];
    } else {
        $reuse = '1';
    }

    $response->header( -'Content-Type' => 'application/x-sapshortcut' );

    return <<SHORTCUT;
[System]
Name=$sysname
Description=$sysdesc$client
[User]
Name=$username
Language=$lang
[Function]
Title=$title
Command=$transaction
[Configuration]
WorkDir=$wd
[Options]
Reuse=$reuse
SHORTCUT
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: %$AUTHOR%

Copyright (C) 2008-2012 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
