package T::Storage::Local;

use Moo;
use namespace::autoclean;

extends 'T::Local';

has 'init_called' => (is => 'rwp', default => sub {0});
sub init { shift->_set_init_called(1) }

1;
