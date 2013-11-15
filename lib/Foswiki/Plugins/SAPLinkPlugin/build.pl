#!/usr/bin/perl -w
BEGIN { unshift @INC, split( /:/, $ENV{FOSWIKI_LIBS} ); }
use Foswiki::Contrib::Build;

# Create the build object
$build = new Foswiki::Contrib::Build('SAPLinkPlugin');

# (Optional) Set the details of the repository for uploads.
# This can be any web on any accessible Foswiki installation.
# These defaults will be used when expanding tokens in .txt
# files, but be warned, they can be overridden at upload time!

# name of web to upload to
$build->{UPLOADTARGETWEB} = 'Extensions';
# Full URL of pub directory
$build->{UPLOADTARGETPUB} = 'http://modell-aachen.de';
# Full URL of bin directory
$build->{UPLOADTARGETSCRIPT} = 'http://modell-aachen.de';
# Script extension
$build->{UPLOADTARGETSUFFIX} = '';

sub _linkFiles {
    my ( $dir ) = @_;
    print "processing dir $dir\n";
    chdir $dir || die "unable to enter $dir";
    foreach my $file ( <'*'> ) {
        my $localfile = "$dir/$file";
        my $other = $localfile;
        $other =~ s#/_source##;
        if ( -d $localfile ) {
            unless ( -d $other ) {
                print "creating directory $other";
                mkdir $other;
            }
            print "entering directory...\n";
            _linkFiles( $localfile );
            chdir $dir;
        } else {
            $other =~ s#(\.js|\.css)$#_src$1#;
            unless ( -e $other ) {
                print "linking $localfile to $other\n";
                symlink( $localfile, $other ) || die "could not create symlink!";
            }
        }
    }
}

use Cwd;
use FindBin;
my $saveddir = getcwd;
my $dir = $FindBin::Bin;
chdir($dir);
unless ( -e "$dir/build.pl" && $dir =~ m#/lib/Foswiki/Plugins/SAPLinkPlugin$# ) {
    print "\nRunning from '$dir'\nPlease call from SAPLinkPlugin/lib/Foswiki/Plugins/SAPLinkPlugin/\n\n";
    exit 1;
}
$dir =~ s#/lib/Foswiki/Plugins/SAPLinkPlugin$#/pub/System/CKEditorPlugin/ckeditor/_source#;
print "Symlinking _source...\n";
_linkFiles($dir);

chdir $saveddir;

# Build the target on the command line, or the default target
$build->build($build->{target});

