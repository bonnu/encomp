use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin::A;
    use Encomp::Plugin qw/+ClassAccessor/;

    class_accessor foo => 'hello';

    no  Encomp::Plugin;

    package Foo::Plugin::B;
    use Encomp::Plugin;

    plugins qw/Foo::Plugin::A/;

    __PACKAGE__->foo('bye');

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

package Foo2;
use Encomp;
incorporate 'Foo';
hook_to '/main' => sub {
    my $self = shift;
    $self->foo($self->foo . '!!');
};
no  Encomp;

package Foo3;
use Encomp;
incorporate 'Foo';
plugins 'Foo::Plugin::B';
no  Encomp;

package main;

note 'retry: Isn\'t there influence in the class data?';
for (0 .. 1) {
    is  +Foo->build->foo, 'hello';
    is  +Foo->operate->foo, 'world';
}

note 'retry: Isn\'t there influence in the inherited class data?';
for (0 .. 1) {
    is  +Foo2->build->foo, 'hello';
    is  +Foo2->operate->foo, 'world!!';
}

note 'retry: Isn\'t there influence in the inherited class data?';
for (0 .. 1) {
    is  +Foo3->build->foo, 'bye';
    is  +Foo3->operate->foo, 'world';
}
