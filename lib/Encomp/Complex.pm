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
        *{$ns . '::can'}      = \&_can;
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
        Encomp::Util::load_class($controller);
        my $plugins   = $controller ->composite->seek_all_plugins;
        my $plugins_e = $encompasser->composite->seek_all_plugins;
        my $methods   = _conflate_methods(@{$plugins}, $controller, @{$plugins_e});
        my $hooks     = _conflate_hooks(@{$plugins}, $controller, @{$plugins_e}, $encompasser);
        my %any       = (methods => $methods, hooks => $hooks);
        _conflate_any(\%any, $plugins, $controller, $plugins_e, $encompasser);
        $COMPLEX{$encompasser}{$controller} = \%any;
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
    delete $methods{$_} for qw/__ANON__ ISA BEGIN can isa/, grep /^_/, keys %methods;
    map { /::$/o && delete $methods{$_} } keys %methods;
    \%methods;
}

sub _conflate_hooks {
    my (@classes) = @_;
    my %hooks;
    for my $class (uniq @classes) {
        my $hooks = $class->composite->hooks;
        for my $point (keys %{$hooks}) {
            push @{$hooks{$point} ||= []}, @{$hooks->{$point}};
        }
    }
    \%hooks;
}

sub _conflate_any {
}

sub _autoload {
    my $proto = shift;
    my $name  = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    my $ns = $1;
    if (my $code = $proto->complex->{methods}{$name}) {
        do {
            no strict 'refs';
            *{$ns . '::' . $name} = $code;
        };
        return wantarray ? ($code->($proto, @_)) : $code->($proto, @_);
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

sub _can {
    $_[0]->complex->{methods}{$_[1]} || UNIVERSAL::can(@_);
}

sub dischain {
    my ($class, $obj) = @_;
    return $obj;
}

1;

__END__
