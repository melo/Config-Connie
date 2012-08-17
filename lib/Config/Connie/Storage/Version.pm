package Config::Connie::Storage::Version;

use Moo::Role;
use namespace::autoclean;

has 'version' => (
  is      => 'lazy',
  builder => 'get_storage_version',
  writer  => '_set_version',
  clearer => 1,
);

sub get_storage_version { }

1;
