package T::Cache::Config;

use Moo;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Registry',
  'Config::Connie::Subscriptions',
  'Config::Connie::Cache',
  ;

sub default_config_id {'test_id'}

1;
