#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use T::Cache::Config;

my $cc = 'T::Cache::Config';

subtest 'basics' => sub {
  my $i = $cc->instance;
  cmp_deeply($i->_cache, {}, 'Cache is empty');

  is($i->_cache_get('k1'), undef, 'key doesnt exists, _cache_get() returns undef');
  ok(!$i->_cache_exist('k1'), '... and _cache_exists() returns false');
  cmp_deeply($i->_cache, {}, '... finally _cache_get() doesnt autovivify nothing on our cache storage');

  is($i->_cache_set(k1 => 42), 42, '_cache_set() returns the value we set');
  is($i->_cache_get('k1'), 42, '... _cache_get() returns the value we set');
  ok($i->_cache_exist('k1'), '... _cache_exists() returns true');

  $i->_cache_set(k2 => 63);
  $i->_cache_set(k3 => 84);
  cmp_deeply([sort $i->_cache_keys], ['k1', 'k2', 'k3'], '_cache_keys() returns list of keys');
};


subtest 'cache signals' => sub {
  my $i = $cc->instance;
  my $c = 0;

  ok(!$i->_cache_updated(k1 => 42),
    '_cache_updated() returns false if the key update was not signalled to subscribers');
  is($c, 0, '... no callbacks called');

  $i->subscribe('k1', sub { $c++ });

  ok($i->_cache_updated(k1 => 42), '_cache_updated() returns true if the key update was signalled to subscribers');
  is($c, 1, '... k1 callback called');

  ok(!$i->_cache_updated(k2 => 42), '_cache_updated() on a different key');
  is($c, 1, '... k1 callback was not called');
};


done_testing();
