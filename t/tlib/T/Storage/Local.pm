package T::Storage::Local;

use Moo;
use namespace::autoclean;

extends 'Config::Connie::Storage::Local';

has 'init_called' => (is => 'rwp', default => sub {0});
sub init { shift->_set_init_called(1) }

1;
