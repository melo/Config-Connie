package Config::Connie;

# ABSTRACT: a very cool module
# VERSION
# AUTHORITY

use strict;
use warnings;



=encoding utf8

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
