package MyConfig;

use Config::Connie::Object;
use Config::Connie::Storage::Redis;
use MyConfigClient;

extends 'Config::Connie';


sub default_app_name {'my_app_name'}

# With real-life code, default_app_env() would probably be like this:
#   sub default_app_env  { $ENV{MYCONFIG_ENV} || 'devel'}
sub default_app_env {'devel'}

sub default_client_class {'MyConfigClient'}


## Register our client handle
## In this example we'll use the Redis storage backend

MyConfig->register(storage => Config::Connie::Storage::Redis->new);

1;
