#!perl

use lib 't/tlib';
use strict;
use warnings;
use Test::More;
use Test::Deep;
use MyConfig;


subtest 'get/set' => sub {
  my $c = MyConfig->client;

  is($c->get('he'), undef, 'get() returns undef for unkown keys');
  is($c->set('he', 'human'), 'human', 'set() returns setted value');
  is($c->get('he'), 'human', '... and sets the value for future gets()s');
};


subtest 'config changes' => sub {
  my $c = MyConfig->client;

  my $cfg1;
  my $cb1 = sub { my ($cln, $k, $v) = @_; $cfg1 = { $k => $v } };
  my $id1 = $c->subscribe('x1' => $cb1);
  ok($id1, 'subscribe() returns a true subscription ID');

  $c->set('x1' => 'y1');
  cmp_deeply($cfg1, { 'x1' => 'y1' }, 'set() calls registered subscribers');

  $c->set('x2' => 'y2');
  cmp_deeply($cfg1, { 'x1' => 'y1' }, '... but only matching our subscriber key');

  my $cfg2;
  my $cb2 = sub { my ($cln, $k, $v) = @_; $cfg2 = { $k => $v } };
  my $id2 = $c->subscribe('x1' => $cb2);
  ok($id2, 'subscribe() returns a true subscription ID');

  $c->set('x1' => 'y3');
  cmp_deeply($cfg1, { 'x1' => 'y3' }, 'set() calls registered subscribers');
  cmp_deeply($cfg2, { 'x1' => 'y3' }, '... all subscribers are called');

  my $cfg3;
  my $cb3 = sub { my ($cln, $k, $v) = @_; $cfg3 = { $k => $v } };
  my $id3 = $c->subscribe('y1' => $cb3);
  ok($id3, 'subscribe() returns a true subscription ID');

  $c->set('y1' => 'z1');
  cmp_deeply($cfg1, { 'x1' => 'y3' }, 'set() only calls...');
  cmp_deeply($cfg2, { 'x1' => 'y3' }, '...  registered subscribers ...');
  cmp_deeply($cfg3, { 'y1' => 'z1' }, '...  that match our key');

  is($c->unsubscribe($id2), $cb2,  'unsubscribe() returns the callback');
  is($c->unsubscribe($id2), undef, '... or undef if subscription ID is not valid/found');

  $c->set('x1' => 'y4');
  cmp_deeply($cfg1, { 'x1' => 'y4' }, 'set() only calls...');
  cmp_deeply($cfg2, { 'x1' => 'y3' }, '...  active subscribers ...');
  cmp_deeply($cfg3, { 'y1' => 'z1' }, '...  that match our key');

  is($c->unsubscribe($id1), $cb1, 'unsubscribe() returns the callback, again');

  $c->set('x1' => 'y5');
  cmp_deeply($cfg1, { 'x1' => 'y4' }, 'set() only calls...');
  cmp_deeply($cfg2, { 'x1' => 'y3' }, '...  active subscribers ...');
  cmp_deeply($cfg3, { 'y1' => 'z1' }, '...  that match our key');

  is($c->unsubscribe($id3), $cb3, 'unsubscribe() returns the callback, again');

  $c->set('y1' => 'z2');
  cmp_deeply($cfg1, { 'x1' => 'y4' }, 'set() only calls...');
  cmp_deeply($cfg2, { 'x1' => 'y3' }, '...  active subscribers ...');
  cmp_deeply($cfg3, { 'y1' => 'z1' }, '...  that match our key');

  ### Just make sure we cleanup after ourselfs
  cmp_deeply($c->_subs, { i => {}, k => {} }, 'subscription database is empty');
};


done_testing();
