package Config::Connie::Storage;

use Moo::Role;
use Carp ();
use namespace::autoclean;

has 'storage' => (is => 'lazy', builder => '_build_storage', handles => ['check_for_updates']);
has 'storage_class' => (is => 'lazy', builder => 'build_storage_class');

sub _build_storage {
  my $stor = shift->build_storage;
  $stor->init;

  return $stor;
}

sub build_storage {
  my ($self) = @_;

  return $self->storage_class->new(instance => $self);
}

sub build_storage_class { Carp::confess "Class '" . ref(shift) . "' requires a build_storage_class method" }


1;
