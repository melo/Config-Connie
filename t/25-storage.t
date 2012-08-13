#!perl

use lib 't/tlib';
use strict;
use warnings;
use Test::More;
use Test::Fatal;
use T::Storage::Config;

my $cc = 'T::Storage::Config';

subtest 'basics' => sub {
  my $i = $cc->setup;

  ok(defined($i->{storage}),     'Has storage attribute just after setup()');
  ok($i->{storage}->init_called, '... and the init() method was called');

  is($i->_cache_get('k'), undef, 'key k not found');
  $i->storage->key_updated('k' => 42);
  is($i->_cache_get('k'), 42, 'key k was updated from Storage');

  ok($i->can('check_for_updates'), "method 'check_for_updates' is available");
  is(exception { $i->check_for_updates }, undef, 'check_for_updates() does not die');
};


subtest 'version' => sub {
  my $i = $cc->setup;

  is($i->version, $$, 'initial version as expected');

  $i->storage->key_updated(k => 42);
  is($i->version, $$ + 1, 'version was updated');

  $i->storage->key_updated(k => 42);
  is($i->version, $$ + 2, 'version was updated again');
};


done_testing();
