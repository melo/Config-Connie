package T::Storage::Local;

use Moo;
use namespace::autoclean;

extends 'T::Local';
with 'Config::Connie::Storage::Version';

has 'init_called' => (is => 'rwp', default => sub {0});

sub init { shift->_set_init_called(1) }

sub get_storage_version {$$}

after 'key_updated' => sub {
  my ($self) = @_;

  $self->_set_version($self->version + 1);
};


1;
