package Config::Connie::Storage;

use Config::Connie::Object;

############
# Our client

has 'client' => (is => 'ro', required => 1);


######################
# Lifecycle management

sub init              { }
sub check_for_updates { }

#######
# Hooks

sub key_updated { die "Class '$_[0]' needs to implement key_updated()" }

1;
