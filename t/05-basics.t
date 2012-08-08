#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use Test::Fatal;
use T::Basic::Config;

my $cc = 'T::Basic::Config';

subtest 'instances' => sub {
  my $i1 = $cc->instance;
  ok($i1, 'Got something from instance()');
  isa_ok($i1, 'T::Basic::Config', '... of the proper type');

  my $i2 = $cc->instance;
  is($i1, $i2, 'Same instance returned on all instance() calls');

  my $i3 = $cc->setup;
  ok($i3, 'Got something from setup()');
  isa_ok($i3, 'T::Basic::Config', '... of the proper type');
  isnt($i3, $i1, '... but a different instance');
};


subtest 'id' => sub {
  my $i1 = $cc->instance;
  is($i1->id, 'test_id', "default ID for $cc");

  my $i2 = $cc->setup(id => 'other_id');
  is($i2->id, 'other_id', '... but we can override it on setup()');
};


done_testing();
