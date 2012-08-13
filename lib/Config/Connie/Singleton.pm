package Config::Connie::Singleton;

use Moo::Role;
use namespace::autoclean;

our %instances;

sub instance {
  my $class = shift;
  return $instances{$class} || $class->setup(@_);
}

sub setup {
  my $class = shift;

  my $i = $instances{$class} = $class->new(@_);
  $i->init;

  return $i;
}

sub init { }

1;
