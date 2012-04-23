#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Fatal;
use Config::Connie;
use Scalar::Util ();

my $cc = 'Config::Connie';

subtest 'direct registry' => sub {
  is($cc->client('a' => 'e'), undef, 'No client found for App a Env e');

  my $cci = $cc->register(app => 'a', env => 'e');
  ok($cci, 'Got something out of Connie->register()');
  is(Scalar::Util::blessed($cci), $cc, "... a $cc object");
  is($cc->instance('a' => 'e'), $cci, 'instance() returns same object');

  my $ccc = $cc->client('a' => 'e');
  ok($ccc, 'Got something out of Connie->client() now');
  is(Scalar::Util::blessed($ccc), 'Config::Connie::Client', "... a ::Client object");
  is($ccc->instance, $cci, '... linked to the proper Connie instance');
  is($cci->client,   $ccc, '->client() to Connie instance, returns same client object');

  is($ccc->app, $cci->app, 'Client and Connie instance have same app attr');
  is($ccc->env, $cci->env, '... same env attr');
  is($ccc->id,  $cci->id,  '... and same id attr');

  is(
    Scalar::Util::blessed($ccc->storage),
    'Config::Connie::Storage::Local',
    'Storage attr has default helper'
  );
};


subtest 'app class registry' => sub {
  is($cc->client('MyConfig'), undef, 'No client found for MyConfig App config class');

  require MyConfig;
  my $mc = MyConfig->client;
  ok($mc, 'Found App config client now');
  my $mci = $mc->instance;
  ok($mci, '... has a Connie instance');
  is(Scalar::Util::blessed($mci), 'MyConfig', '... with the proper type');
  is($cc->instance('MyConfig'),   $mci,       '... same instance we get from Connie->instance');

  my $mca = $cc->client($mci->app, $mci->env);
  ok($mca, 'Found App config client via app/env combo');

  my $mcai = $mca->instance;
  is(Scalar::Util::blessed($mcai), 'MyConfig', '... with the proper type');

  is($mcai, $mci, 'In fact, they are the same object');

  is(Scalar::Util::blessed($mci->storage), 'MyStorageHelper', 'Expected custom storage object');
};


subtest 'bad register calls' => sub {
  like(exception { $cc->register }, qr{^Missing attr 'app'}, 'No app attr given');
  like(
    exception { $cc->register(app => 'app', storage => {}) },
    qr{^Missing attr 'env'},
    'No env attr given'
  );
};


done_testing();
