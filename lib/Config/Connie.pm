package Config::Connie;

# ABSTRACT: a very cool module
# VERSION
# AUTHORITY

use Moo::Role;
use namespace::autoclean;

with
  'Config::Connie::ID',
  'Config::Connie::Registry',
  'Config::Connie::Storage',
  'Config::Connie::Subscriptions',
  'Config::Connie::Cache',
  'Config::Connie::Defaults',
  'Config::Connie::Client',
  ;

1;

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

Each application can have multiple environments. Each application environment
can have multiple configuration key, and each one has a configuration hash.


=head2 Components

The system has two components: client and manager.

Apps use a client component to access configuration keys and to listen for
changes Connie provides utilities to manage these objects as singletons

Manager allows you to list available configuration keys, get and update them.


=cut

