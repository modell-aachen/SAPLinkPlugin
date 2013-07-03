# ---+ Extensions
# ---++ SAPLinkPlugin

# **SELECT sap-shortcut, web**
# Method to be used
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkMethod} = 'sap-shortcut';

# **STRING**
# ServerName f&uuml;r web-Links.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkServer} = '';

# **STRING**
# ServerPath f&uuml;r web-Links.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkPath} = '';

# **STRING**
# SystemName f&uuml;r sap-shortcuts.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkSystemName} = '';

# **STRING**
# System Description f&uuml;r sap-shortcuts.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkSystemDesc} = '';

# **STRING**
# SystemName f&uuml;r sap-shortcuts.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkWorkingDir} = '';

# **STRING**
# User-Name f&uuml;r sap-shortcuts.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkUserName} = '%WIKINAME%';

# **STRING**
# Client-Id f&uuml;r sap-shortcuts.
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkUserClient} = '001';

# **STRING**
# Standard-Sprache f&uuml;r sap-shortcuts.
# <p>Diese Einstellung <b>muss</b> korrekt sein, ansonsten kann eine laufende
# Session nicht weiter genutzt werden.</p>
$Foswiki::cfg{Plugins}{SAPLinkPlugin}{SAPLinkLanguage} = 'D';
