package Commit::Cruncher;

use Commit::Cruncher::Processor;

sub go {
  my $class = shift;
  # may process options and feed it to ::Settings one day
  Commit::Cruncher::Processor->doitall(@_);
}

1;
