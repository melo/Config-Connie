package Config::Connie::Storage;

use Moo::Role;
use Carp ();
use namespace::autoclean;

has 'storage' => (is => 'lazy', builder => 'build_storage', handles => ['check_for_updates']);
has 'storage_class' => (is => 'lazy', builder => 'build_storage_class');

sub build_storage {
  my ($self) = @_;

  return $self->storage_class->new(instance => $self);
}

sub build_storage_class { Carp::confess "Class '" . ref(shift) . "' requires a build_storage_class method" }

after 'init' => sub { shift->storage->init() };

1;
