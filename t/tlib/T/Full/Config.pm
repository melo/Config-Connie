package T::Full::Config;

use Moo;
use T::Local;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Singleton',
  'Config::Connie::Storage',
  'Config::Connie::Subscriptions',
  'Config::Connie::Cache',
  'Config::Connie::Defaults',
  'Config::Connie::Client',
  ;

sub default_config_id {'defaults_id'}

sub build_storage_class {'T::Local'}

1;
