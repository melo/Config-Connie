package T::Defaults::Config;

use Moo;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Registry',
  'Config::Connie::Defaults',
  ;

sub default_config_id {'defaults_id'}

1;
