package Config::Connie::Client;

use Moo::Role;
use namespace::autoclean;

requires 'subscribe', 'storage', '_cache_get', '_cache_exist', '_cache_set', 'default_for';

sub get {
  my ($self, $k) = @_;

  return $self->_cache_get($k) if $self->_cache_exist($k);
  return $self->default_for($k);
}

sub _set {
  my ($self, $k, $v, $immediate) = @_;

  $self->_cache_set($k, $v) if $immediate;
  $self->storage->key_updated($k, $v);

  return $v;
}

sub set { $_[0]->_set($_[1], $_[2]) }
sub set_now { $_[0]->_set($_[1], $_[2], 1) }

sub config {
  my ($self, $k, $cb, @rest) = @_;

  $self->subscribe($k, $cb, @rest);

  my $v = $self->get($k);
  $cb->($v, $k, $self, \@rest);

  return;
}

1;
