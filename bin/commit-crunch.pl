#!/usr/bin/perl

use File::Spec;
use FindBin qw($RealBin);
use lib File::Spec->catfile($RealBin, "..", "lib");

use Commit::Cruncher;

Commit::Cruncher->go(@ARGV);
