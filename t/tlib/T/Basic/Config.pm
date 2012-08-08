package T::Basic::Config;

use Moo;
use namespace::autoclean;

with
  'Config::Connie::Core',
  'Config::Connie::Singleton',
  ;

sub default_config_id {'test_id'}

1;
