package Config::Connie::Client;

use Config::Connie::Object;

has 'instance' => (is => 'ro', required => 1);

has 'app'     => (is => 'ro', default => sub { shift->instance->app });
has 'env'     => (is => 'ro', default => sub { shift->instance->env });
has 'storage' => (is => 'ro', default => sub { shift->instance->storage });

1;
