use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;

BEGIN {
    package Foo::Encompasser::A;
    use Encomp;

    config '04_config.yaml';

    no  Encomp;

    package Foo::Encompasser::B;

    use Encomp;

    config
        common  => { foo  => 'bar' },
        plugins => { hoge => 1     },
    ;

    no  Encomp::Plugin;
}

package main;

is_deeply
    +Foo::Encompasser::A->composite->stash->{config},
    {
        common  => { foo  => 'FOO', baz  => '1.111' },
        plugins => { fuga => 2 },
    },
;

is_deeply
    +Foo::Encompasser::B->composite->stash->{config},
    {
        common  => { foo  => 'bar' },
        plugins => { hoge => 1     },
    },
;
