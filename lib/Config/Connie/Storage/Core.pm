package Config::Connie::Storage::Core;

use Moo::Role;
use namespace::autoclean;

requires 'check_for_updates', 'key_updated';

has 'instance' => (is => 'ro', weak_ref => 1, required => 1);

sub init { }

1;
