package Commit::Cruncher::Processor;

use Commit::Cruncher::Settings;
use Commit::Cruncher::Commit;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $file = shift;
    my $self = {};
    $self->{file} = $file;
    $self->{parsed} = 0;
    bless $self, $class;
    return $self
}

sub my_die {
  print shift() . "\n";
  exit(1);
}

sub parse {
    my $self = shift;
    if($self->{parsed} == 1) {
      return;
    }
    my $F;
    open $F, "<", $self->{file} or my_die("Failed opening " . $self->{file} . ": " . $!);
    my @lines = <$F>;
    my @input_lines = ();
    my @matching = ();
    my @old_generated_lines = ();
    my $state = 1;
    my $magic = magic();
    foreach my $line(@lines) {
      if($state == 1 && $line =~ /^:(?:Completed|Old|New) Commit(?:\(s\)|s|):$/) {
        $state = 2; redo;
      } elsif($state == 1 && $line =~ /((?:$magic).+)$/) {
        push @matching, $1;
        $state = 3; redo;
      } elsif($state == 2 && ($line =~ /^:(?:Completed|Old|New) Commit(?:\(s\)|s|):$/ || $line =~ /^\s*$/ || $line =~ /^($magic)+.*$/)) {
        push @old_generated_lines, $line;
      } else {
        push @input_lines, $line;
        $state = 1;
      }
    }
    @{$self->{input_lines}} = @input_lines;
    @{$self->{commits}} = @{[map { Commit::Cruncher::Commit->new($_) } @matching]};
    $self->{parsed} = 1;
}

sub completed_commits {
  my $self = shift;
  grep { $_->is_completed() } @{$self->{commits}};
}

sub old_commits {
  my $self = shift;
  grep { $_->is_old() } @{$self->{commits}};
}

sub new_commits {
  my $self = shift;
  grep { $_->is_new() } @{$self->{commits}};
}

sub file {
  return shift->{file};
}

sub save {
  my $self = shift;
  my $file = shift || $self->file;
  my $FH;
  open $FH, ">", $file;
  $self->_save($FH);
  close $FH;
}

sub print {
  shift->_save(*STDOUT);
}

sub _save {
    my $self = shift;
    my $FH = shift;
    unless($self->{parsed} == 1) {
      my_die("Internal error.");
    }
    my $last = "\n";
    foreach(@{$self->{input_lines}}) {
      print $FH $_;
      $last = $_;
    }
    my @completed = $self->completed_commits();
    my @new = $self->new_commits();
    my @old = $self->old_commits();
    print $FH "\n" unless($last eq "\n");
    output_header($FH, "Completed", @completed);
    output_header($FH, "New", @new);
    output_header($FH, "Old", @old);
}

sub _person_cmp {
  my ($a, $b) = @_;
  return $a->person cmp $b->person;
}

sub _age_cmp {
  my ($a, $b) = @_;
  return -1 * ( $a->age <=> $b->age );
}

sub _same_person {
  my ($a, $b) = @_;
  return $a->person eq $b->person;
}

sub _same_age {
  my ($a, $b) = @_;
  return $a->age == $b->age;
}

sub commit_sort {
#  return sort {if(_same_person($a, $b)) { _age_cmp($a, $b) } else { _person_cmp($a, $b) } } @_;
  return sort {if(_same_age($a, $b)) { _person_cmp($a, $b) } else { _age_cmp($a, $b) } } @_;
}

sub output_header {
  my ($FH, $name) = (shift, shift);
  my @commits = @_;
  if(scalar(@commits) == 0) {
    return;
  }
  my $s = "";
  if(scalar(@commits) > 1) {
    $s = "s"
  }
  print $FH ":$name Commit$s:\n";
  foreach my $commit(commit_sort(@commits)) {
    print $FH $commit->string . "\n";
  }
  print $FH "\n";
}

sub magic {
  return $Commit::Cruncher::Settings::MAGIC_CHAR;
}

sub doitall {
    my $class = shift;
    my $self = $class->new(@_);
    $self->parse;
    $self->save;
    $self->print;
}

1;
