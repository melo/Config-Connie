package MyStorageIsDelayed;

use Config::Connie::Object;

extends 'Config::Connie::Storage';

has '_queue' => (is => 'ro', default => sub { [] });

sub key_updated {
  my ($self, $k, $v) = @_;

  push @{ $self->_queue }, [$k, $v];
}

sub check_for_updates {
  my ($self) = @_;
  my $client = $self->client;
  my $queue  = $self->_queue;

  while (my $item = pop @$queue) {
    $client->_update_key(@$item);
  }
}


1;
