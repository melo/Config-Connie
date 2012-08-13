#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use T::Defaults::Config;

my $cc = 'T::Defaults::Config';

subtest 'defaults' => sub {
  my $i1 = $cc->setup;

  is($i1->default_for('k'), undef, "No default for 'k'");

  $i1->default_for('k' => { answer => 42 });
  cmp_deeply($i1->default_for('k'), { answer => 42 }, 'After default_for() set, we get back proper result');

  my $i2 = $cc->instance;
  cmp_deeply($i2->default_for('k'), { answer => 42 }, 'default_for() returns same info for second instance()');

  my $i3 = $cc->setup;
  is($i3->default_for('k'), undef, "No default for 'k' on new instance");
};


done_testing();
