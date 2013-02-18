#!/usr/bin/perl -w
BEGIN { unshift @INC, split( /:/, $ENV{FOSWIKI_LIBS} ); }
use Foswiki::Contrib::Build;

package SAPLinkPluginBuild;
our @ISA = qw( Foswiki::Contrib::Build );


sub new {
    my $class = shift;
    return bless( $class->SUPER::new( 'SAPLinkPlugin' ));
}

# Will first symlink _source files to plugins directory and do a standard build
sub target_compress {
    my $this = shift;

    # Symlink the source to ..._src.js files and return to current dir
    my $dir = "$this->{basedir}/pub/System/CKEditorPlugin/ckeditor/_source";
    my $saveddir = `pwd`;
    $saveddir =~ m#(.*)#; # filter out newline
    $saveddir = $1;
    print "Symlinking _source...\n";
    _linkFiles($dir);
    chdir $saveddir;

    # do a standard compress
    $this->SUPER::target_compress(@ARGV);
}

# This function will recursively call itself and link files from _source to
# the plugins-dir with _src suffix where appropriate.
# Initial call should point $dir to _source directory.
sub _linkFiles {
    my ( $dir ) = @_;
    print "processing dir $dir\n";
    chdir $dir || die "unable to enter $dir";
    foreach my $file ( <*> ) {
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


# Create the build object
$build = new SAPLinkPluginBuild();

# Standard build script from here on...

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

# Build the target on the command line, or the default target
$build->build($build->{target});

