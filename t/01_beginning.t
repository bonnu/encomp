use strict;
use warnings;
use Test::More 'no_plan';

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
    package Foo::Plugin;

    use Encomp::Plugin;

    hook_to '/initialize' => sub {
        my $self = shift;
    };

    no  Encomp::Plugin;
}

CONTROLLER_DEFINITION_BLOCK :
{
    package Foo::Controller;

    use Encomp::Controller;
    use Data::Dumper;

    hook_to '/initialize'      => sub { shift->{data}++ };
    hook_to '/dispatch'        => sub { shift->{data}++ };
    hook_to '/dispatch/before' => sub { shift->{data}++ };
    hook_to '/dispatch/main'   => sub { shift->{data}++ };
    hook_to '/dispatch/after'  => sub { shift->{data}++ };
    hook_to '/finalize'        => sub { shift->{data}++ };

    hook_to '/finalize'        => sub {
        my $self = shift;
        no strict 'refs';
        print Dumper($self);
        $self->test;
    };

    sub test { ::is shift->{data}, 6 }

    no  Encomp::Controller;
}

ok  +Foo->isa('Encomp::Class::Encompasser');

Foo->operate('Foo::Controller');
