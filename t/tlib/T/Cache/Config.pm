package T::Cache::Config;

use Moo;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Singleton',
  'Config::Connie::Subscriptions',
  'Config::Connie::Cache',
  ;

sub default_config_id {'test_id'}

1;
