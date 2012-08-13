package Config::Connie::ID;

use Moo::Role;
use namespace::autoclean;

requires 'default_config_id';

has 'id' => (is => 'lazy', builder => 'default_config_id');

1;
