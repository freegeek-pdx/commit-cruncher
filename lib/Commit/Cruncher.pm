package Commit::Cruncher;

use Commit::Cruncher::Processor;

sub go {
  my $class = shift;
  if(scalar(@_) != 1) {
    print "Usage: commit-crunch filename.txt\n";
    exit(1);
  }
  # may process options and feed it to ::Settings one day
  Commit::Cruncher::Processor->doitall(@_);
}

1;
