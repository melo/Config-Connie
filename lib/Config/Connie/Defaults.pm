package Config::Connie::Defaults;

use Moo::Role;
use namespace::autoclean;

has 'defaults' => (is => 'ro', default => sub { {} });

sub default_for {
  my ($self, $k, $def) = @_;
  $self = $self->instance unless ref($self);

  my $defs = $self->defaults;

  return $defs->{$k} = $def if defined $def;
  return $defs->{$k} if exists $defs->{$k};
  return;
}

1;
