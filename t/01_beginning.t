use strict;
use warnings;
use Test::More 'no_plan';
use Class::Inspector;

ENCOMPASSER_DEFINITION_BLOCK :
{
    package Foo;

    use Encomp qw/+Accessor/;

    accessor 'data';

    sub incr { shift->{data}++ }

    processes
        initialize =>
        dispatch   => [
            before =>
            main   =>
            after  =>
        ] =>
        finalize   =>
    ;

    no  Encomp;
}

PLUGIN_DEFINITION_BLOCK :
{
    {
        package Foo::Plugin::A;

        use Encomp::Plugin;

        sub method_a { 'a' }

        sub method_overrided { __PACKAGE__ }

        hook_to '/dispatch/main' => sub { shift->incr };

        no  Encomp::Plugin;
    }

    {
        package Foo::Plugin::B;

        use Encomp::Plugin;

        plugins 'Foo::Plugin::A';

        sub method_b { 'b' }

        no  Encomp::Plugin;
    }

    {
        package Foo::Plugin::C;

        use Encomp::Plugin;

        plugins 'Foo::Plugin::B';

        sub method_c { 'c' }

        sub method_overrided { __PACKAGE__ }

        no  Encomp::Plugin;
    }
}

CONTROLLER_DEFINITION_BLOCK :
{
    package Foo::Controller;

    use Encomp::Controller;

    plugins qw/
        Foo::Plugin::C
        Foo::Plugin::A
    /;

    hook_to '/initialize'      => sub { shift->incr    };
    hook_to '/initialize'      => sub { shift->test_01 };
    hook_to '/dispatch'        => sub { shift->incr    };
    hook_to '/dispatch/before' => sub { shift->incr    };
    hook_to '/dispatch/main'   => sub { shift->incr    };
    hook_to '/dispatch/after'  => sub { shift->test_02 };
    hook_to '/finalize'        => sub { };

    sub test_01 {
        my $self = shift;
        ::is +$self->method_a, 'a';
        ::is +$self->method_b, 'b';
        ::is +$self->method_c, 'c';
    }

    sub test_02 {
        my $self = shift;
        ::is +$self->data, 5;
        ::is +$self->method_overrided, 'Foo::Plugin::C';
    }

    no  Encomp::Controller;
}

ok  +Foo            ->isa('Encomp::Class::Encompasser');
ok  +Foo::Plugin::A ->isa('Encomp::Class::Plugin');
ok  +Foo::Plugin::B ->isa('Encomp::Class::Plugin');
ok  +Foo::Controller->isa('Encomp::Class::Controller');

my $foo = Foo->operate('Foo::Controller');

ok $foo->loaded('Foo::Plugin::A');
ok $foo->loaded('Foo::Plugin::B');
ok $foo->loaded('Foo::Plugin::C');
ok not $foo->loaded('Foo::Plugin::D');

is_deeply
    [ Foo->node->get_all_ids ],
    [
        initialize =>
        dispatch   => [
           before  =>
           main    =>
           after   =>
        ] =>
        finalize   =>
    ];
