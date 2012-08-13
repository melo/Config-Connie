package T::Local;

use Moo;
use namespace::autoclean;

with 'Config::Connie::Storage::Core';

sub key_updated       { shift->instance->_cache_updated(@_) }
sub check_for_updates { }

1;
