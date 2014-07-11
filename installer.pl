#!/usr/bin/perl
use strict;
use warnings;
use File::Temp 'tempdir';

my $HELP = <<"...";
Usage:
    > perl $0

Environment variables:

    INSTALL_DRYRUN       if true, show commands to be executed and exit.
    INSTALL_GOVERSION    go version to be installed. default 1.2.1
    INSTALL_GOROOT       where to install. default ~/.go

Example:
    > INSTALL_DRYRUN=1 perl $0
    > INSTALL_GOROOT=$ENV{HOME}/my-go perl $0
...

if (@ARGV && $ARGV[0] =~ /-h/) {
    print $HELP;
    exit;
}

sub run {
    my $cmd = shift;
    print "-> $_\n" for split /\n/, $cmd;
    return if $ENV{INSTALL_DRYRUN};
    !system "bash", "-c", $cmd or die "=> FAILED $cmd\n";
}
sub cd {
    my $dir = shift;
    print "-> cd $dir\n";
    return if $ENV{INSTALL_DRYRUN};
    chdir $dir or die "=> FAILED cd $dir: $!";
}

my $go_version       = $ENV{INSTALL_GOVERSION} || "1.2.1";
my $go_src           = "go${go_version}.src.tar.gz";
my $go_url           = "http://golang.org/dl/$go_src";
my $go_root          = $ENV{INSTALL_GOROOT} || "$ENV{HOME}/.go";
my $crosscompile_url = "git://github.com/davecheney/golang-crosscompile.git";

if (!$ENV{INSTALL_DRYRUN} && -e $go_root) {
    die "ERROR already exists '$go_root', please remove it and try again.\n";
}

my @remove = grep { /^GO/ } keys %ENV;
delete $ENV{$_} for @remove;

my $tempdir = tempdir CLEANUP => 1;
cd $tempdir;
run "curl -s -O -L $go_url";
run "tar xf $go_src";
run "mv go $go_root";

cd "$go_root/src";
run "./all.bash";
run "git clone -q $crosscompile_url $go_root/misc/golang-crosscompile";
run <<"...";
set -e
source $go_root/misc/golang-crosscompile/crosscompile.bash
export PATH=$go_root/bin:$ENV{PATH}
go-crosscompile-build-all
...

my $message = <<"...";
Don't forget to set the followings in your .bashrc or .zshrc:
export PATH=$go_root/bin:\$PATH
source $go_root/misc/golang-crosscompile/crosscompile.bash
...

if (!$ENV{INSTALL_DRYRUN}) {
    print
        "\e[32m",
        "Successfully installed go to $go_root with crosscompile settings.",
        "\e[m",
        "\n",
        $message;
}


