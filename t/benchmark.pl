use strict;
use warnings;
use Benchmark qw/cmpthese timethese/;

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

    sub plugin_method { shift->{data}++ }

    no  Encomp::Plugin;
}

CONTROLLER_DEFINITION_BLOCK :
{
    package Foo::Controller;

    use Encomp::Controller;

    plugins 'Foo::Plugin';

    hook_to '/initialize'      => sub { shift->{data}++ };
    hook_to '/dispatch'        => sub { shift->{data}++ };
    hook_to '/dispatch/before' => sub { shift->{data}++ };
    hook_to '/dispatch/main'   => sub { shift->{data}++ };
    hook_to '/dispatch/after'  => sub { shift->{data}++ };
    hook_to '/finalize'        => sub { shift->plugin_method };
    hook_to '/finalize'        => sub { $_[0]->test };

#   sub test { print $_[0]->{data} == 5 ? 'ok' : 'ng', "\n" }
    sub test { $_[0]->{data} == 6 }

    no  Encomp::Controller;
}

cmpthese(10000, {
    'operate' => sub { Foo->operate('Foo::Controller') },
});
