use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin::A;
    use Encomp::Plugin qw/+Accessor +ClassAccessor/;

    sub a { __PACKAGE__ }

    accessor       'hello';
    class_accessor 'config' => { foo => 1 };

    no  Encomp::Plugin;

    package Foo::Plugin::B;
    use Encomp::Plugin;

    plugins 'Foo::Plugin::A';

    sub b { __PACKAGE__ }

    no  Encomp::Plugin;

    package Foo::Plugin::C;
    use Encomp::Plugin;

    plugins 'Foo::Plugin::B';

    sub c { __PACKAGE__ }

    no  Encomp::Plugin;

    package Foo::Plugin::D;
    use Encomp::Plugin;

    plugins 'Foo::Plugin::C';

    plugout 'Foo::Plugin::A';

    sub d { __PACKAGE__ }

    no  Encomp::Plugin;

    package Foo::Plugin::E;
    use Encomp::Plugin;

    plugins 'Foo::Plugin::D';

    sub e { __PACKAGE__ }

    no  Encomp::Plugin;
}

package Foo;
use Encomp;
processes qw/foo bar baz/;
no  Encomp;

package Foo::Controller;
use Encomp::Controller;

plugins 'Foo::Plugin::A';

hook_to '/foo' => sub {
    my $self = shift;
    ::ok    $self->hello('world');
};

hook_to '/bar' => sub {
    my $self = shift;
    ::ok    $self->hello('hello ' . $self->hello);
};

hook_to '/baz' => sub {
    my $self = shift;
    ::is        +$self->hello,           'hello world';
    ::is_deeply +$self->config,          { foo => 1 }, 'refer to class data';
    __PACKAGE__->config({ bar => 2 });
    ::is_deeply +__PACKAGE__->config,    { bar => 2 }, 'refer to inherited class data';
    $self->config({ baz => 3 });
    ::is_deeply +$self->config,          { baz => 3 }, 'refer to instance data';
    ::is_deeply +Foo::Plugin::A->config, { foo => 1 }, 'class data is not changed';
};

no  Encomp::Controller;

package main;

Foo->operate('Foo::Controller');

my $b = Foo->build('Foo::Plugin::B');
can_ok +$b, 'a';
can_ok +$b, 'b';
ok !   +$b->can('c'), '$b->can\'t(\'c\')';
ok !   +$b->can('d'), '$b->can\'t(\'d\')';
ok !   +$b->can('e'), '$b->can\'t(\'e\')';

my $c = Foo->build('Foo::Plugin::C');
can_ok +$c, 'a';
can_ok +$c, 'b';
can_ok +$c, 'c';
ok !   +$c->can('d'), '$c->can\'t(\'d\')';
ok !   +$c->can('e'), '$c->can\'t(\'e\')';

my $d = Foo->build('Foo::Plugin::D');
TODO: {
    local $TODO = '';
    ok !   +$d->can('a'), '$d->can\'t(\'a\')';
};
can_ok +$d, 'b';
can_ok +$d, 'c';
can_ok +$d, 'd';
ok !   +$d->can('e'), '$d->can\'t(\'e\')';

my $e = Foo->build('Foo::Plugin::E');
TODO: {
    local $TODO = '';
    ok !   +$e->can('a'), '$e->can\'t(\'a\')';
};
can_ok +$e, 'b';
can_ok +$e, 'c';
can_ok +$e, 'd';
can_ok +$e, 'e';
