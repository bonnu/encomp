use strict;
use warnings;
use Test::More 'no_plan';
use Benchmark qw/cmpthese timethese/;
use Data::Dumper;

ENCOMPASSER_DEFINITION_BLOCK :
{
    package Foo;

    use Encomp;

    plugins 'Foo::Plugin::A';

    processes
        'initialize',
        'dispatch' => [qw/
            before
            main
            after
        /],
        'finalize',
    ;

    no  Encomp;
}

PLUGIN_DEFINITION_BLOCK :
{
    package Foo::Plugin::A;

    use Encomp::Plugin;

    sub method_a { 'a' }

    no  Encomp::Plugin;

    package Foo::Plugin::B;

    use Encomp::Plugin;

    plugins 'Foo::Plugin::A';

    sub method_b { 'b' }

    no  Encomp::Plugin;

    package Foo::Plugin::C;

    use Encomp::Plugin;

    plugins 'Foo::Plugin::B';

    sub method_c { 'c' }

    no  Encomp::Plugin;
}

CONTROLLER_DEFINITION_BLOCK :
{
    package Foo::Controller;

    use Encomp::Controller;
    use Data::Dumper;

    plugins 'Foo::Plugin::C';

    hook_to '/initialize'      => sub { shift->{data}++; 1 };
    hook_to '/initialize'      => sub { shift->test_01 ; 1 };
    hook_to '/dispatch'        => sub { shift->{data}++; 1 };
    hook_to '/dispatch/before' => sub { shift->{data}++; 1 };
    hook_to '/dispatch/main'   => sub { shift->{data}++; 1 };
    hook_to '/dispatch/after'  => sub { shift->test_02 ; 1 };

    sub test_01 {
        my $self = shift;
        ::is +$self->method_a, 'a';
        ::is +$self->method_b, 'b';
        ::is +$self->method_c, 'c';
    }

    sub test_02 {
        my $self = shift;
        ::is +$self->{data}, 4;
    }

    no  Encomp::Controller;
}

ok  +Foo->isa('Encomp::Class::Encompasser');

Foo->operate('Foo::Controller');
