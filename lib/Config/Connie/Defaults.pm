package Config::Connie::Defaults;

use Moo::Role;
use namespace::autoclean;

requires 'instance';

has '_defaults' => (is => 'ro', default => sub { {} });

sub default_for {
  my $self = shift;
  my $k    = shift;
  my $d    = $self->_defaults;

  return $d->{$k} = shift if @_;
  return $d->{$k} if exists $d->{$k};
  return;
}

1;
