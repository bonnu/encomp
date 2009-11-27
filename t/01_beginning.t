use strict;
use warnings;
use Test::More 'no_plan';
use Class::Inspector;

ENCOMPASSER_DEFINITION_BLOCK :
{
    package Foo;

    use Encomp;

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
    {
        package Foo::Plugin::A;

        use Encomp::Plugin;

        sub method_a { 'a' }

        hook_to '/dispatch/main' => sub { shift->{data}++ };

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

        no  Encomp::Plugin;
    }
}

CONTROLLER_DEFINITION_BLOCK :
{
    package Foo::Controller;

    use Encomp::Controller;

    plugins 'Foo::Plugin::C';

    hook_to '/initialize'      => sub { shift->{data}++; 1    };
    hook_to '/initialize'      => sub { shift->test_01 ; 1    };
    hook_to '/dispatch'        => sub { shift->{data}++; 1    };
    hook_to '/dispatch/before' => sub { shift->{data}++; 1    };
    hook_to '/dispatch/main'   => sub { shift->{data}++; 1    };
    hook_to '/dispatch/after'  => sub { shift->test_02 ; 1    };
    hook_to '/finalize'        => sub { shift->test_03(@_); 1 };

    sub test_01 {
        my $self = shift;
        ::is +$self->method_a, 'a';
        ::is +$self->method_b, 'b';
        ::is +$self->method_c, 'c';
    }

    sub test_02 {
        my $self = shift;
        ::is +$self->{data}, 5;
    }

    sub test_03 {
        my ($self, $context) = @_;
    }

    no  Encomp::Controller;
}

ok  +Foo            ->isa('Encomp::Class::Encompasser');
ok  +Foo::Plugin::A ->isa('Encomp::Class::Plugin');
ok  +Foo::Plugin::B ->isa('Encomp::Class::Plugin');
ok  +Foo::Controller->isa('Encomp::Class::Controller');

Foo->operate('Foo::Controller');

ok  +Foo::_complexed::Foo::Controller->can('method_a');

is_deeply
    +Class::Inspector->methods('Foo::_complexed::Foo::Controller'),
    [qw/
        AUTOLOAD
        can
        complex
        method_a
        method_b
        method_c
        test_01
        test_02
        test_03
    /],
    'deeply';
