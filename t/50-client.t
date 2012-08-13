#!perl

use lib 't/tlib';
use strict;
use warnings;
use Test::More;
use Test::Deep;
use T::Full::Config;

my $cc = 'T::Full::Config';

subtest 'get/set' => sub {
  my $i = $cc->setup;

  is($i->get('he'), undef, 'get() returns undef for unkown keys');
  is($i->set('he', 'human'), 'human', 'set() returns setted value');
  is($i->get('he'), 'human', '... and sets the value for future gets()s');

  is($i->get('here'), undef, "get() with 'here' key is undef");
  is($i->get('here', 'boo'), 'boo', "... but return local default if given");

  cmp_deeply([sort $i->list], ['he'], 'list() returns list of keys');
};


subtest 'config changes' => sub {
  my $i = $cc->setup;

  my $cfg1;
  my $cb1 = sub { my ($v, $k, $ins) = @_; $cfg1 = { kv => { $k => $v }, ins => $ins } };
  my $id1 = $i->subscribe('x1' => $cb1);
  ok($id1, 'subscribe() returns a true subscription ID');

  $i->set('x1' => 'y1');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y1' }, ins => $i }, 'set() calls registered subscribers');

  $i->set('x2' => 'y2');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y1' }, ins => $i }, '... but only matching our subscriber key');

  my $cfg2;
  my $cb2 = sub { my ($v, $k, $ins) = @_; $cfg2 = { kv => { $k => $v }, ins => $ins } };
  my $id2 = $i->subscribe('x1' => $cb2);
  ok($id2, 'subscribe() returns a true subscription ID');

  $i->set('x1' => 'y3');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y3' }, ins => $i }, 'set() calls registered subscribers');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, ins => $i }, '... all subscribers are called');

  my $cfg3;
  my $cb3 = sub {
    my ($v, $k, $ins, $rest) = @_;
    $cfg3 = { kv => { $k => $v }, ins => $ins, rest => $rest };
  };
  my $id3 = $i->subscribe('y1' => $cb3, { t => 1, r => 2 });
  ok($id3, 'subscribe() returns a true subscription ID');

  $i->set('y1' => 'z1');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y3' }, ins => $i }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, ins => $i }, '...  registered subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, ins => $i, rest => [{ t => 1, r => 2 }] }, '...  that match our key');

  is($i->unsubscribe($id2), $cb2,  'unsubscribe() returns the callback');
  is($i->unsubscribe($id2), undef, '... or undef if subscription ID is not valid/found');

  $i->set('x1' => 'y4');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y4' }, ins => $i }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, ins => $i }, '...  active subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, ins => $i, rest => [{ t => 1, r => 2 }] }, '...  that match our key');

  is($i->unsubscribe($id1), $cb1, 'unsubscribe() returns the callback, again');

  $i->set('x1' => 'y5');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y4' }, ins => $i }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, ins => $i }, '...  active subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, ins => $i, rest => [{ t => 1, r => 2 }] }, '...  that match our key');

  is($i->unsubscribe($id3), $cb3, 'unsubscribe() returns the callback, again');

  $i->set('y1' => 'z2');
  cmp_deeply($cfg1, { kv => { 'x1' => 'y4' }, ins => $i }, 'set() only calls...');
  cmp_deeply($cfg2, { kv => { 'x1' => 'y3' }, ins => $i }, '...  active subscribers ...');
  cmp_deeply($cfg3, { kv => { 'y1' => 'z1' }, ins => $i, rest => [{ t => 1, r => 2 }] }, '...  that match our key');

  ### Just make sure we cleanup after ourselfs
  cmp_deeply($i->_cfg_subs, { i => {}, k => {} }, 'subscription database is empty');
};


subtest 'slow storage' => sub {
  require T::Full::Storage;
  my $i = $cc->setup(storage_class => 'T::Full::Storage');

  my $notif_v;
  $i->subscribe('key', sub { $notif_v = $_[0] });

  is($i->get('key'), undef, 'get() returns undef for unknown keys');
  is($i->set('key', 'value'), 'value', 'set() returns setted value');
  is($i->get('key'), undef, '... but local cache not updated when storage is down');
  is($notif_v,       undef, '... nor is a notification sent');

  $i->check_for_updates;
  is($notif_v, 'value', 'Notification was received after check_for_updates()');

  undef $notif_v;
  is($i->set_now('key', 'value2'), 'value2', 'set_now() also returns setted value');
  is($i->get('key'), 'value2', '... but local cache is updated immediatly, even with storage down');
  is($notif_v,       undef,    '... still, no notification is sent');

  $i->check_for_updates;
  is($notif_v, 'value2', 'Notification was received after check_for_updates()');
};


subtest 'one stop shop for config' => sub {
  my $i = $cc->setup;
  $i->default_for('xx' => 2);

  my $vg;
  $i->config('xx' => sub { my ($v, undef, undef, $args) = @_; $vg = $v * $args->[0] }, 5);
  is($vg, 10, 'config() callback called immediatly');

  $i->set(xx => 3);
  is($vg, 15, '... and after each set()');
};


done_testing();
