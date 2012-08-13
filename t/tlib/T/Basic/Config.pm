package T::Basic::Config;

use Moo;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Singleton',
  ;

sub default_config_id {'test_id'}

1;
