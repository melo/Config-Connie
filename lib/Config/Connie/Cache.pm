package Config::Connie::Cache;

use Moo::Role;
use namespace::autoclean;

requires '_signal_subscribers';

has '_cache' => (is => 'ro', default => sub { {} });

sub _cache_get { my ($self, $k) = @_; my $c = $self->_cache; return unless exists $c->{$k}; return $c->{$k} }
sub _cache_exist { my ($self, $k) = @_; exists $self->_cache->{$k} }
sub _cache_set { my ($self, $k, $v) = @_; $self->_cache->{$k} = $v }

sub _cache_keys { keys %{ $_[0]->_cache } }

sub _cache_updated {
  my ($self, $k, $v) = @_;

  $self->_cache->{$k} = $v;
  return $self->_signal_subscribers($k, $v);
}

1;
