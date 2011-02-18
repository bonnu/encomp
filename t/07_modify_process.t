use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo;
    use Encomp;
    processes
        foo  =>
        bar  =>
        baz  =>
        qux  =>
        quux =>
    ;
    no  Encomp;
}

my @results;

{
    package Foo::Plugin::Modifier;
    use Encomp::Plugin;
    modify_process before => sub {
        my ($node, $context) = @_;
        push @results, $context->current->get_path . ' : before';
    };
    modify_process around => sub {
        my ($orig_sub, $node, $context) = @_;
        push @results, $context->current->get_path . ' : around';
        $orig_sub->($node, $context);
    };
    modify_process after => sub {
        my ($node, $context) = @_;
        push @results, $context->current->get_path . ' : after';
    };
}

Foo->operate;

is_deeply \@results, [];

Foo->operate('Foo::Plugin::Modifier');

is_deeply \@results, [
    '/ : around',
    '/ : before',
    '/ : after',
    '/foo : around',
    '/foo : before',
    '/foo : after',
    '/bar : around',
    '/bar : before',
    '/bar : after',
    '/baz : around',
    '/baz : before',
    '/baz : after',
    '/qux : around',
    '/qux : before',
    '/qux : after',
    '/quux : around',
    '/quux : before',
    '/quux : after'
];
