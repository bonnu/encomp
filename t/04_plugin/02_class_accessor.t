use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin::A;
    use Encomp::Plugin qw/+ClassAccessor/;

    class_accessor foo => 'hello';

    no  Encomp::Plugin;
}

package Foo;
use Encomp;
processes qw/main/;
plugins qw/Foo::Plugin::A/;
hook_to '/main' => sub {
    my $self = shift;
    $self->foo('world');
};
no  Encomp;

package main;

# diag 'retry: Isn\'t there influence in the class data?';
for (0 .. 1) {
    is  +Foo->build->foo, 'hello';
    is  +Foo->operate->foo, 'world';
}
