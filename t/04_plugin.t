use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    package Foo::Plugin;
    use Encomp::Plugin qw/
        +Accessor +Class::Accessor
    /;
    accessor 'hello';
    no  Encomp::Plugin;
}

package Foo;
use Encomp;
processes qw/
    foo bar baz
/;
no  Encomp;

package Foo::Controller;
use Encomp::Controller;

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
    ::is    +$self->hello, 'hello world';
};


