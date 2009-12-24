use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin::A;
    use Encomp::Plugin qw/+DuckType/;
    duck_type 'foo';
    duck_type 'bar';
    duck_type 'baz';
    no  Encomp::Plugin;

    package Foo::Plugin::KnowsA;
    use Encomp::Plugin qw/+Accessor +ClassAccessor/;
    accessor  'foo';
    class_accessor 'bar' => 1;
    sub baz { 'baz' }
    no  Encomp::Plugin;
}

package Foo;
use Encomp;
plugins qw/Foo::Plugin::A/;
no  Encomp;

package main;

eval { Foo->build };

my $e = $@;
# diag "Error:\n", $@;

for (qw/foo bar baz/) {
    like +$e, qr/"$_" duck_type is defined by these modules: Foo::Plugin::A/ms;
}

ok      +Foo->build('Foo::Plugin::KnowsA');
