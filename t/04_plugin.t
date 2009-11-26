use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin;
    use Encomp::Plugin qw/+Accessor +ClassAccessor/;

    accessor       'hello';
    class_accessor 'config' => { foo => 1 };

    no  Encomp::Plugin;
}

package Foo;
use Encomp;
processes qw/foo bar baz/;
no  Encomp;

package Foo::Controller;
use Encomp::Controller;

plugins 'Foo::Plugin';

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
    ::is        +$self->hello,        'hello world';
    ::is_deeply +$self->config,       { foo => 1 }, 'refer to class data';
    $self->config({ aaa => 2 });
    ::is_deeply +$self->config,       { aaa => 2 }, 'refer to instance data';
    ::is_deeply +Foo::Plugin->config, { foo => 1 }, 'class data is not changed';
};

no  Encomp::Controller;

package main;

Foo->operate('Foo::Controller');
