package T::Storage::Config;

use Moo;
use T::Storage::Local;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Singleton',
  'Config::Connie::Subscriptions',
  'Config::Connie::Cache',
  'Config::Connie::Storage',
  ;

sub default_config_id {'defaults_id'}

sub build_storage_class {'T::Storage::Local'}

1;
