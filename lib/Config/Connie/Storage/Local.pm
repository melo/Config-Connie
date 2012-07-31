package Config::Connie::Storage::Local;

use Moo;
use namespace::autoclean;

extends 'Config::Connie::Storage';

sub key_updated {
  my ($self, $k, $v) = @_;

  $self->client->_update_key($k => $v);
}

1;
