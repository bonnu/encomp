package Encomp::Complex;

use strict;
use warnings;
use Carp qw/croak/;

my %COMPLEX;

sub build {
    my $class = shift;
    my $ns    = $class->_conflate(@_);
    bless {}, $ns;
}

sub _conflate {
    my ($class, $encompasser, $controller) = @_;
    my $ns      = __generate_ns($encompasser, $controller);
    my $complex = $COMPLEX{$encompasser} ||= {};
    unless (exists $complex->{$controller}) {
        my $plugins = __conflate_plugins($encompasser, $controller);
        my $methods = __conflate_methods($controller, $plugins);
        $complex->{$controller} = {
            methods => $methods,
            plugins => $plugins,
        };
        do {
            no strict 'refs';
            *{$ns . '::AUTOLOAD'} = \&_autoload;
        };
    }
    return $ns;
}

sub __generate_ns {
    my ($encompasser, $controller) = @_;
    my $ns = join '::', $encompasser, '__complex__', $controller;
}

sub __split_ns {
    my $ns = shift;
    split '::__complex__::', $ns;
}

sub __conflate_methods {
    my ($controller, $plugins) = @_;
    my %methods;
    for my $class ($controller, @{$plugins}) {
        my $entries = do { no strict 'refs'; \%{$class . '::'} };
        %methods = (%methods, %{$entries});
    }
    delete $methods{$_} for qw/__ANON__ ISA BEGIN/;
    \%methods;
}

sub __conflate_plugins {
    my ($encompasser, $controller) = @_;
    my @plugins;
    for my $role ($controller, $encompasser) {
        $role->composite->seek_all_plugins(\@plugins);
    }
    \@plugins;
}

sub _autoload {
    my $self = shift;
    my $name = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    my $ns = $1;
    my ($encompasser, $controller) = __split_ns($ns);
    my $complex = $COMPLEX{$encompasser};
    if (my $code = $complex->{$controller}{methods}{$name}) {
        do {
            no strict 'refs';
            *{$ns . '::' . $name} = $code;
        };
        return wantarray ? ($code->($self, @_)) : $code->($self, @_);
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $self || $self) . '"';
}

sub clean {
    my ($class, $obj) = @_;
}

1;

__END__
