#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use T::Subscriptions::Config;

my $cc = 'T::Subscriptions::Config';

subtest 'management' => sub {
  my $i1 = $cc->instance;
  cmp_deeply($i1->_cfg_subs, {}, 'No subscriptions, empty state');

  my $s1 = $i1->subscribe('k1', sub { });
  ok($s1, 'Got one subscription ID');
  my $s2 = $i1->subscribe('k1', sub { });
  ok($s2, '... and the second one');

  $i1->unsubscribe($s1);
  $i1->unsubscribe($s2);
  cmp_deeply($i1->_cfg_subs, { i => {}, k => {} }, 'After all unsubscribes, no more subs');
};


subtest 'signal management' => sub {
  my $i1 = $cc->instance;

  is($i1->_signal_subscribers('k1', 'sig'), undef, 'No subscribers for key, undef is returned');

  $i1->subscribe('k1', sub { });
  is($i1->_signal_subscribers('k1', 42), 1, 'one subscriber from k1');

  $i1->subscribe('k1', sub { });
  is($i1->_signal_subscribers('k1', 42), 2, 'and now two subscriber from k1');

  $i1->subscribe(
    'k1',
    sub {
      my ($v, $k, $i, $args) = @_;
      pass('k1 callback was called');
      is($v, 42,   '... expected value');
      is($k, 'k1', '... and key');
      cmp_deeply($args, [{ answer => 84 }, "true"], '... rest of arguments match also');
      is($i, $i1, 'proper C::C instance received');
    },
    { answer => 84 },
    "true",
  );
  is($i1->_signal_subscribers('k1', 42), 3, 'three subscribers were notified');
};


done_testing();
