#!perl

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Deep;
use Test::Exception;
use Async::Gate;

my $g = Async::Gate->new;
ok(!$g->is_open);
ok($g->is_closed);
ok(!$g->is_locked);

my %called;
$g->on_open(sub {
  $called{o1}++;
});
ok(!$g->is_open);
ok($g->is_closed);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

### anoymous open()
$g->open();
ok(!$g->is_closed);
ok($g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, { o1 => 1 });

### on_open() on a open gate, calls immediatly
$g->on_open(sub {
  $called{o2}++;
});
ok(!$g->is_closed);
ok($g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, { o1 => 1, o2 => 1 });

### open() with open gate, dies
throws_ok(
  sub { $g->open },
  qr/Can't call open() on a already open gate,/
);
ok(!$g->is_closed);
ok($g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, { o1 => 1, o2 => 1 });

### close and open with lock
%called = ();
$g->close;
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->lock;
ok($g->is_locked);

$g->open();
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->on_open(sub {
  $called{o3}++;
});
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->open();
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->unlock;
ok(!$g->is_closed);
ok($g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, { o1 => 1, o2 => 1, o3 => 1 });

### named keys without locks
%called = ();
$g->close;
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->add_key('k1');
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->add_key('k2');
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->open('k1');
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->add_key('k3');
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->open('k2');
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->open('k3');
ok(!$g->is_closed);
ok($g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, { o1 => 1, o2 => 1, o3 => 1 });

### named keys with locks
%called = ();
$g->close;
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->add_key('k1');
ok($g->is_closed);
ok(!$g->is_open);
ok(!$g->is_locked);
cmp_deeply(\%called, {});

$g->lock;
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->add_key('k2');
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->open('k1');
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->open('k2');
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->add_key('k3');
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

$g->open('k3');
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, { o1 => 1, o2 => 1, o3 => 1 });

$g->unlock;
ok($g->is_closed);
ok(!$g->is_open);
ok($g->is_locked);
cmp_deeply(\%called, {});

