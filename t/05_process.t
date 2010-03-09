use strict;
use warnings;
use Test::More qw/no_plan/;

package Foo;

use Encomp;

plugins 'Foo::Plugin::Body';

processes
    1 => [qw/ 1 2 3 /],
    2 => [qw/ 1 2 3 /],
    3 => [qw/ 1 2 3 /],
    4 => [qw/ 1 2 3 /],
    5 => [qw/ 1 2 3 /],
;

hook_to '/1/1' => sub { my $self = shift; $self->body('/1/1'); $self->context->goto('/2')   };
hook_to '/1/2' => sub { my $self = shift; $self->body('/1/2'); $self->context->goto('/2/2') };
hook_to '/1/3' => sub { my $self = shift; $self->body('/1/3'); $self->context->goto('/2/3') };
                                                                             
hook_to '/2/1' => sub { my $self = shift; $self->body('/2/1'); $self->context->goto('/3')   };
hook_to '/2/2' => sub { my $self = shift; $self->body('/2/2'); $self->context->goto('/3/2') };
hook_to '/2/3' => sub { my $self = shift; $self->body('/2/3'); $self->context->goto('/3/3') };
                                                                             
hook_to '/3/1' => sub { my $self = shift; $self->body('/3/1'); $self->context->goto('/4')   };
hook_to '/3/2' => sub { my $self = shift; $self->body('/3/2'); $self->context->goto('/4/2') };
hook_to '/3/3' => sub { my $self = shift; $self->body('/3/3'); $self->context->goto('/4/3') };
                                                                             
hook_to '/4/1' => sub { my $self = shift; $self->body('/4/1'); $self->context->goto('/5')   };
hook_to '/4/2' => sub { my $self = shift; $self->body('/4/2'); $self->context->goto('/5/2') };
hook_to '/4/3' => sub { my $self = shift; $self->body('/4/3'); $self->context->goto('/5/3') };
                                                                             
hook_to '/5/1' => sub { my $self = shift; $self->body('/5/1'); $self->context->goto('/1/2') };
hook_to '/5/2' => sub { my $self = shift; $self->body('/5/2'); $self->context->goto('/1/3') };
hook_to '/5/3' => sub { my $self = shift; $self->body('/5/3') };

no  Encomp;

package Foo::Plugin::Body;

use Encomp::Plugin;

sub body {
    my $self = shift;
    $self->{txt} ||= q{};
    $self->{txt} .= $_[0] . "\n" if 0 < @_;
    return $self->{txt};
}

no  Encomp::Plugin;

package main;

my $foo = Foo->operate('Foo');

is  +$foo->body, <<__EOS__;
/1/1
/2/1
/3/1
/4/1
/5/1
/1/2
/2/2
/3/2
/4/2
/5/2
/1/3
/2/3
/3/3
/4/3
/5/3
__EOS__
