package Config::Connie;

# ABSTRACT: a very cool module
# VERSION
# AUTHORITY

use Config::Connie::Object;
use Config::Connie::Client;
use Config::Connie::Storage::Local;
use Carp 'confess';
use Scalar::Util 'weaken';


#######################
# App + Env identifiers

has 'app' => (is => 'ro', default => sub { shift->default_app_name });
has 'env' => (is => 'ro', default => sub { shift->default_app_env });

sub default_app_name { confess "Missing attr 'app'" }
sub default_app_env  { confess "Missing attr 'env'" }


###############
# App config ID

has 'id' => (is => 'ro', default => sub { my ($s) = @_; _id($s->app, $s->env) });

sub _id { return join('.', @_) }


#######################
# App config management

{
  my %instances;

  sub register {
    my $class = shift;
    my $self  = $class->new(@_);

    $instances{class}{$class} = $self if $class ne __PACKAGE__;
    return $instances{id}{ $self->id } = $self;
  }

  sub instance {
    my ($class, $app, $env) = @_;

    my ($key, $bd) = @_;
    if ($app && $env) {
      $key = _id($app, $env);
      $bd = $instances{id};
    }
    elsif ($app) {
      $key = $app;
      $bd  = $instances{class};
    }
    else {
      $key = $class;
      $bd  = $instances{class};
    }

    return unless exists $bd->{$key};
    return $bd->{$key};
  }
}


###################
# Client management

has '_client_cache' => (
  is => 'ro',

# FIXME: simple version that would work if Mo::weaken existed
#  default => sub { Config::Connie::Client->new(instance => $_[0]) },
  default => sub {
    ### HACK HACK HACK until we have Mo::weaken
    my $cln = Config::Connie::Client->new(instance => $_[0]);
    weaken($cln->{instance});
    weaken($cln->storage->{client});

    return $cln;
  }
);

sub client {
  my $self = shift;

  $self = $self->instance(@_) unless ref $self;
  return unless $self;

  return $self->_client_cache;
}


####################
# Storage management

has 'storage_builder' => (is => 'ro');

sub storage {
  my ($self, $client) = @_;
  my $stor = $self->storage_builder;

  $stor = $stor->(client => $client) if $stor;
  $stor = Config::Connie::Storage::Local->new(client => $client) unless $stor;
  $stor->init;

  return $stor;
}


##################
# Pool for updates

sub check_for_updates {
  shift->client->storage->check_for_updates(@_);
}


=encoding utf8

=head1 SYNOPSIS

First create your configuration object.

    ## Declare your Connie config for clients to use
    Config::Connie->register(
      app  => 'my_app_1',
      env  => 'devel',
      
      ## A storage 
      storage => Config::Connie::Storage::Redis->new,
    );
    
    
    ## Or define a class for your system
    package MyConfig;
    
    use strict;
    use parent 'Config::Connie';
    
    sub default_app_name { 'my_app_name' }
    sub default_app_env  { 'devel' } ## Probably a bit more dynamic in real life
    
    ## Register our client handle
    ## In this example we'll use the Redis storage backend
    MyConfig->register(
      storage => Config::Connie::Storage::Redis->new
    );
    
    1;


Then later on your app to get a client handle:

    my $cln = Config::Connie->client('my_app_1' => 'devel');
    ## or...
    my $cln = MyConfig->client;


=head1 DESCRIPTION

Configuration is organized on three level system:

=over 4

=item application

The application identifier.

=item environment

The environment to use, like production, development, or staging.

=item configuration key

A arbitrary string.

=back

Each application can have multiple environments. Each application
environment can have multiple configuration key, and each one has a
configuration hash.


=head2 Components

The system has two components: client and manager.

Apps use a client component to access configuration keys and to listen
for changes Connie provides utilities to manage these objects as
singletons

Manager allows you to list available configuration keys, get and update them.


=cut

1;
