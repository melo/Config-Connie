package T::Defaults::Config;

use Moo;
use namespace::autoclean;

with
  'Config::Connie::Core',
  'Config::Connie::Singleton',
  'Config::Connie::Defaults',
  ;

sub default_config_id {'defaults_id'}

1;
