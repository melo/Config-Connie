#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Fatal;
use Config::Connie;
use Scalar::Util 'blessed';

my $cc = 'Config::Connie';

subtest 'direct registry' => sub {
  is($cc->client('a' => 'e'), undef, 'No client found for App a Env e');

  my $cci = $cc->register(app => 'a', env => 'e', storage => bless({}, 'StoreIt'));
  ok($cci, 'Got something out of Connie->register()');
  is(blessed($cci), $cc, "... a $cc object");

  my $ccc = $cc->client('a' => 'e');
  ok($ccc, 'Got something out of Connie->client() now');
  is(blessed($ccc), 'Config::Connie::Client', "... a ::Client object");
  is($ccc->instance, $cci, '... linked to the proper Connie instance');

  is($ccc->app,              $cci->app,     'Client and Connie instance have same app attr');
  is($ccc->env,              $cci->env,     '... same env attr');
  is($ccc->storage,          $cci->storage, '... and same storage attr');
  is(blessed($ccc->storage), 'StoreIt',     'Storage attr is of the expected type');
};


subtest 'app class registry' => sub {
  is($cc->client('MyConfig'), undef, 'No client found for MyConfig App config class');

  require MyConfig;
  my $mc = MyConfig->client;
  ok($mc, 'Found App config class now');
  my $mci = $mc->instance;
  is(blessed($mci), 'MyConfig', '... with the proper type');

  my $mca = $cc->client($mci->app, $mci->env);
  ok($mca, 'Found App config class via app/env combo');
  is(blessed($mca), 'MyConfigClient', '... client is blessed into the proper type');

  my $mcai = $mca->instance;
  is(blessed($mcai), 'MyConfig', '... with the proper type');

  is($mcai, $mci, 'In fact, they are the same object');

  is(blessed($mci->storage), 'Config::Connie::Storage::Redis', 'Expected storage object');
};


subtest 'bad register calls' => sub {
  like(
    exception { $cc->register(storage => {}) },
    qr{^Missing attr 'app'},
    'No app attr given'
  );
  like(
    exception { $cc->register(app => 'app', storage => {}) },
    qr{^Missing attr 'env'},
    'No env attr given'
  );
  like(
    exception { $cc->register(app => 'app', env => 'env') },
    qr{^Missing attr 'storage'},
    'No storage attr given'
  );
};


done_testing();
