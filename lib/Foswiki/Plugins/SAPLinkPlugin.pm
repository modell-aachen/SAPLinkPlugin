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

our $VERSION = '1.1';

our $RELEASE = '1.1';

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

    Foswiki::Func::registerRESTHandler( 'getlink', \&restGetLink, authenticate => 0, validate => 0, http_allow => 'GET' );

    # Copy/Paste/Modify from MetaCommentPlugin
    if ($Foswiki::cfg{Plugins}{SolrPlugin}{Enabled}) {
      require Foswiki::Plugins::SolrPlugin;
      Foswiki::Plugins::SolrPlugin::registerIndexTopicHandler(
        \&indexTopicHandler
      );
    }

    my $options = 'txt_tra:"%MAKETEXT{"Transaction: "}%"'
        .',display:"'.($Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkDisplay} || 'symbol').'"';
    if($Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkMethod} eq 'web') {
        my $server = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkServer} || return 0;
        my $path = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkPath} || return 0;
        $options .= ",type:'web',nwurl:'http://$server/$path'";
        #return "[[http://$server/$path?~TRANSACTION=$transaction][$image]]";
    } elsif ($Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkMethod} eq 'sap-shortcut') {
        $options .= ",type:'sc'";
    } else {
        $options .= ",type:'unknown'";
    }
    if($Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkRegexp}) {
        my $regexp = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkRegexp};
        $regexp =~ s#\\#\\#g; # use JSON?
        $regexp =~ s#'#\\'#g; # use JSON?
        $options .= ",regexp:'$regexp'";
    }
    if(defined $Foswiki::cfg{Plugins}{SAPLinkPlugin}{UpperCase}) {
        $options .= ",UpperCase:" . (($Foswiki::cfg{Plugins}{SAPLinkPlugin}{UpperCase})?'1':'0');
    }
    $options = Encode::encode($Foswiki::cfg{Site}{CharSet}, $options);
Foswiki::Func::addToZone('script', 'SAPLinkPlugin', <<SCRIPT, 'JQUERYPLUGIN::FOSWIKI');
<style type="text/css">\@import url('%PUBURLPATH%/%SYSTEMWEB%/SAPLinkPlugin/saplink.css');</style>
<script type="text/javascript" src="%PUBURLPATH%/%SYSTEMWEB%/SAPLinkPlugin/saplink.js"></script>
<script type="text/javascript">document.SAPLink={$options}</script>
SCRIPT

    # Plugin correctly initialized
    return 1;
}

sub restGetLink {
    my ( $session, $subject, $verb, $response ) = @_;

    my $query = $session->{request};
    my $param = $query->{param};

    my $system = ''; # Preferences for [System] will go here
    my $user = ''; # Preferences for [User] will go here
    my $config = ''; # Preferences for [Configuration] will go here
    my $options = ''; # Preferences for [Options] will go here
    my $function = ''; # Preferences for [Function] will go here

    my $webtopic = $param->{webtopic};
    my $pushed;
    if ($webtopic) {
        my ($nweb, $ntopic) = Foswiki::Func::normalizeWebTopicName( '', @$webtopic[0] );
        if (Foswiki::Func::topicExists( $nweb, $ntopic ) ) {
           $pushed = 1;
           Foswiki::Func::pushTopicContext( $nweb, $ntopic );
       }
    }

    my $value;

    $value = _getConfig( 'SAPLinkWorkingDir', $param );
    $value = Foswiki::Func::expandCommonVariables($value) if $value;
    $config .= "\nWorkDir=$value" if $value;

    $value = _getConfig( 'SAPLinkUserName', $param );
    $value = Foswiki::Func::expandCommonVariables($value) if $value;
    $user .= "\nName=$value" if $value;

    $value = _getConfig( 'SAPLinkSystemName', $param );
    $system .= "\nName=$value" if $value;

    $value = _getConfig( 'SAPLinkSystemDesc', $param );
    $system .= "\nDescription=$value" if $value;

    $value = _getConfig( 'SAPLinkLanguage', $param );
    $user .= "\nLanguage=$value" if $value;

    $value = _getConfig( 'SAPLinkUserClient', $param );
    $system .= "\nClient=$value" if $value;

    Foswiki::Func::popTopicContext() if $pushed;

    $value = $query->{param}->{transaction}[0] || die; # XXX
    $function .= "\nCommand=$value" if $value;

    $value = $query->{param}->{title};
    $value = @$value[0] if $value;
    $value = 'SAP-Link' unless $value;
    $function .= "\nTitle=$value\nType=Transaction";

    $value = $query->{param}->{reuse};
    if ($value) {
        $value = @$value[0];
    } else {
        $value = '1';
    }
    $options .= " \nReuse=$value";

    $response->header( -'Content-Type' => 'application/x-sapshortcut' );

    my $shortcut = '';

    $shortcut .= "[System]$system\n" if $system;
    $shortcut .= "[User]$user\n" if $user;
    $shortcut .= "[Function]$function\n" if $function;
    $shortcut .= "[Configuration]$config\n" if $config;
    $shortcut .= "[Options]$options\n" if $options;

    return $shortcut;
}

sub _getConfig {
    my ($config, $param) = @_;

    my $value;
    if ($param->{$config}) {
        $value = $param->{$config}[0];
    } else {
        $value = Foswiki::Func::getPreferencesValue( $config )
            || $Foswiki::cfg{Plugins}{SAPLinkPlugin}{$config};
    }
    return Foswiki::Func::expandCommonVariables($value);
}

sub indexTopicHandler {
    my ($indexer, $doc, $web, $topic, $meta, $text) = @_;

    my $reg = $Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkRegexp} || '[a-zA-Z0-9_]+';
    while ( $text =~ m#SAP Transaction: ($reg) #go ) {
        $doc->add_fields( sap_transaction_lst => $1 );
    }
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
