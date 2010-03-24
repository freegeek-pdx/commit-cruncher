package Commit::Cruncher::Commit;

use Commit::Cruncher::Settings;

sub magic {
  return $Commit::Cruncher::Settings::MAGIC_CHAR;
}

sub new {
  my $class = shift;
  my $string = shift;
  my $self = {};
  bless $self, $class;
  $self->{string} = $string;
  my $magic = magic();
  $string =~ m/^((?:$magic)+)\s*(\w+)\s*(.*)$/; # TODO: account for commits like "> Bob and Jack will do X"?
  $self->{magics} = $1;
  $self->{committer} = $2;
  $self->{commitment} = $3;
  $self->{string} = $self->{magics} . " " . $self->{committer} . " " . $self->{commitment};
  return $self;
}

sub age {
  return length(shift->{magics});
}

sub person {
  return shift->{committer};
}

sub is_old {
  my $self = shift;
  $self->age > 1 && !$self->is_completed;
}

sub is_new {
  my $self = shift;
  $self->age == 1 && !$self->is_completed;
}

sub is_completed {
  my $self = shift;
  my @words = ($self->{commitment} =~ /(\w+)/g);
  return $words[scalar(@words) - 1] =~ /^done$/i;
}

sub string {
  return shift->{string};
}

1;
