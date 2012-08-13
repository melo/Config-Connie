package T::Full::Storage;

use Moo;
use namespace::autoclean;

with 'Config::Connie::Storage::Core';

has '_queue' => (is => 'ro', default => sub { [] });

sub key_updated {
  my ($self, $k, $v) = @_;

  push @{ $self->_queue }, [$k, $v];
}

sub check_for_updates {
  my ($self) = @_;
  my $inst   = $self->instance;
  my $queue  = $self->_queue;

  while (my $item = pop @$queue) {
    $inst->_cache_updated(@$item);
  }
}


1;
