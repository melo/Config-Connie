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
  my $cb1 = sub { my ($v, $k, $cln) = @_; $cfg1 = { kv => { $k => $v }, cln => $cln } };
  my $id1 = $c->subscribe('x1' => $cb1);
  ok($id1, 'subscribe() returns a true subscription ID');

  $c->set('x1' => 'y1');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y1' }, cln => $c }, 'set() calls registered subscribers');

  $c->set('x2' => 'y2');
  cmp_deeply(
    $cfg1,
    { kv => { 'x1' => 'y1' }, cln => $c },
    '... but only matching our subscriber key'
  );

  my $cfg2;
  my $cb2 = sub { my ($v, $k, $cln) = @_; $cfg2 = { kv => { $k => $v }, cln => $cln } };
  my $id2 = $c->subscribe('x1' => $cb2);
  ok($id2, 'subscribe() returns a true subscription ID');

  $c->set('x1' => 'y3');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y3' }, cln => $c }, 'set() calls registered subscribers');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, cln => $c }, '... all subscribers are called');

  my $cfg3;
  my $cb3 = sub { my ($v, $k, $cln) = @_; $cfg3 = { kv => { $k => $v }, cln => $cln } };
  my $id3 = $c->subscribe('y1' => $cb3);
  ok($id3, 'subscribe() returns a true subscription ID');

  $c->set('y1' => 'z1');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y3' }, cln => $c }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, cln => $c }, '...  registered subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, cln => $c }, '...  that match our key');

  is($c->unsubscribe($id2), $cb2,  'unsubscribe() returns the callback');
  is($c->unsubscribe($id2), undef, '... or undef if subscription ID is not valid/found');

  $c->set('x1' => 'y4');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y4' }, cln => $c }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, cln => $c }, '...  active subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, cln => $c }, '...  that match our key');

  is($c->unsubscribe($id1), $cb1, 'unsubscribe() returns the callback, again');

  $c->set('x1' => 'y5');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y4' }, cln => $c }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, cln => $c }, '...  active subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, cln => $c }, '...  that match our key');

  is($c->unsubscribe($id3), $cb3, 'unsubscribe() returns the callback, again');

  $c->set('y1' => 'z2');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y4' }, cln => $c }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, cln => $c }, '...  active subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, cln => $c }, '...  that match our key');

  ### Just make sure we cleanup after ourselfs
  cmp_deeply($c->_subs, { i => {}, k => {} }, 'subscription database is empty');
};


subtest 'slow storage' => sub {
  require MyStorageIsDelayed;
  my $i = Config::Connie->register(
    app             => 'app_with_bad_storage',
    env             => 'test',
    storage_builder => sub { MyStorageIsDelayed->new(@_) },
  );
  my $c = $i->client;

  my $notif_v;
  $c->subscribe('key', sub { $notif_v = $_[0] });

  is($c->get('key'), undef, 'get() returns undef for unknown keys');
  is($c->set('key', 'value'), 'value', 'set() returns setted value');
  is($c->get('key'), undef, '... but local cache not updated when storage is down');
  is($notif_v,       undef, '... nor is a notification sent');

  $i->check_for_updates;
  is($notif_v, 'value', 'Notification was received after check_for_updates()');

  undef $notif_v;
  is($c->set_now('key', 'value2'), 'value2', 'set_now() also returns setted value');
  is($c->get('key'), 'value2', '... but local cache is updated immediatly, even with storage down');
  is($notif_v,       undef,    '... still, no notification is sent');

  $i->check_for_updates;
  is($notif_v, 'value2', 'Notification was received after check_for_updates()');
};


done_testing();
