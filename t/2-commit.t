#!perl

use strict;
use warnings;

use File::Path            qw{ remove_tree };
use File::Spec::Functions qw{ catdir };
use Git::Wrapper;
use Test::More tests => 1;

# build fake repository
chdir( catdir('t', 'commit') );
system "git init";
my $git = Git::Wrapper->new('.');
$git->add( qw{ dist.ini Changes } );
$git->commit( { message => 'initial commit' } );

# changelog and dist.ini can be modified
append_to_file('Changes',  "\n");
append_to_file('dist.ini', "\n");
system "dzil release";

# check if dist.ini and changelog have been committed
my ($log) = $git->log( 'HEAD' );
is( $log->message, "v1.23\n\n- foo\n- bar\n- baz\n", 'commit message taken from changelog' );

# clean & exit
remove_tree( '.git' );
unlink 'Foo-1.23.tar.gz';
exit;

sub append_to_file {
    my ($file, @lines) = @_;
    open my $fh, '>>', $file or die "can't open $file: $!";
    print $fh @lines;
    close $fh;
}