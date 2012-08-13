#!perl

use lib 't/tlib';
use strict;
use warnings;
use Test::More;
use Test::Fatal;
use T::Storage::Config;

my $cc = 'T::Storage::Config';
my $i  = $cc->setup;

is($i->_cache_get('k'), undef, 'key k not found');
$i->storage->key_updated('k' => 42);
is($i->_cache_get('k'), 42, 'key k was updated from Storage');

ok($i->can('check_for_updates'), "method 'check_for_updates' is available");
is(exception { $i->check_for_updates }, undef, 'check_for_updates() does not die');

done_testing();
