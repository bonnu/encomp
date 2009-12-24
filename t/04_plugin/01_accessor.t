use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin::A;
    use Encomp::Plugin qw/+Accessor/;

    accessor 'foo';

    no  Encomp::Plugin;
}

package Foo;
use Encomp;
processes qw/main/;
plugins qw/Foo::Plugin::A/;
hook_to '/main' => sub {
    my $self = shift;
    $self->foo('hello');
};
no  Encomp;

package main;

is  +Foo->build->foo, undef;
is  +Foo->operate->foo, 'hello';
is  +Foo->build->foo('world'), 'world';
is  +Foo->build->foo, undef;

my $foo = Foo->build;

$foo->foo('!!');

is  +$foo->foo,   '!!';
is  +$foo->{foo}, '!!';
