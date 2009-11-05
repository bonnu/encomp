package Encomp::Complex;

use strict;
use warnings;
use Carp qw/croak/;
use List::MoreUtils qw/uniq/;

my %COMPLEX;

sub all_complex { \%COMPLEX }

sub build {
    my $class = shift;
    my $ns    = $class->_initialize(@_);
    bless {}, $ns;
}

sub _initialize {
    my ($class, $encompasser, $controller) = @_;
    my $ns = _generate_ns($encompasser, $controller);
    if (_conflate($encompasser, $controller)) {
        no strict 'refs';
        *{$ns . '::AUTOLOAD'} = \&_autoload;
        *{$ns . '::complex'}  = sub { $COMPLEX{$encompasser}{$controller} };
    }
    return $ns;
}

sub _generate_ns {
    my ($encompasser, $controller) = @_;
    my $ns = join '::', $encompasser, '__complex__', $controller;
}

sub _conflate {
    my ($encompasser, $controller) = @_;
    $COMPLEX{$encompasser} ||= {};
    unless ($COMPLEX{$encompasser}{$controller}) {
        my $c_plugins = $controller ->composite->seek_all_plugins;
        my $e_plugins = $encompasser->composite->seek_all_plugins;
        my $methods   =
            _conflate_methods(@{$c_plugins}, $controller, @{$e_plugins});
        my $hooks     =
            _conflate_hooks(@{$c_plugins}, $controller, @{$e_plugins}, $encompasser);
        $COMPLEX{$encompasser}{$controller} = {
            methods => $methods,
            hooks   => $hooks,
        };
        return 1;
    }
    return 0;
}

sub _conflate_methods {
    my (@classes) = @_;
    my %methods;
    for my $class (uniq @classes) {
        my $entries = do { no strict 'refs'; \%{$class . '::'} };
        %methods = (%methods, %{$entries});
    }
    delete $methods{$_} for qw/__ANON__ ISA BEGIN can isa/;
    map { /::$/o && delete $methods{$_} } keys %methods;
    \%methods;
}

sub _conflate_hooks {
    my (@classes) = @_;
    my %hooks;
    for my $class (uniq @classes) {
        my $hook = $class->composite->hook;
        for my $point (keys %{$hook}) {
            push @{$hooks{$point} ||= []}, @{$hook->{$point}};
        }
    }
    \%hooks;
}

sub _autoload {
    my $self = shift;
    my $name = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    my $ns = $1;
    if (my $code = $self->complex->{methods}{$name}) {
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
