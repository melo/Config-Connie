package Config::Connie::Storage;

use Moo::Role;
use namespace::autoclean;

requires 'build_storage';

has 'storage' => (is => 'ro', builder => 'build_storage', handles => ['check_for_updates']);

1;
