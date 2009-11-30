package Encomp::Complex;

use strict;
use warnings;
use Carp qw/croak/;
use List::MoreUtils qw/uniq/;
use Digest::MD5 qw/md5_hex/;

my %COMPLEX;

sub all_complex { \%COMPLEX }

sub build {
    my $class = shift;
    bless {}, _initialize(@_);
}

sub dischain {
    my ($class, $obj) = @_;
    return $obj;
}

sub _initialize {
    my ($encompasser, $controller, $adhoc) = _initial_args(@_);
    my $adhoc_digest = _generate_adhoc_digest($adhoc);
    my $namespace    = _generate_namespace   ($encompasser, $controller, $adhoc_digest);
    my $complex      = _generate_complex     ($encompasser, $controller, $adhoc_digest);
    if ($complex) {
        _conflate($complex, $encompasser, $controller, $adhoc);
        {
            no strict 'refs';
            *{"${namespace}::AUTOLOAD"} = \&_autoload;
            *{"${namespace}::can"}      = \&_can;
            *{"${namespace}::complex"}  = sub { $complex };
        }
    }
    return $namespace;
}

sub _initial_args {
    my ($encompasser, $controller) = @_;
    my @adhoc;
    if (ref $controller eq 'ARRAY') {
        @adhoc      = @{$controller};
        $controller = shift @adhoc;
    }
    return ($encompasser, $controller, \@adhoc);
}

sub _generate_adhoc_digest {
    my $adhoc  = shift;
    my $digest = md5_hex(join '', sort @{$adhoc}) if 0 < @{$adhoc};
    return $digest;
}

sub _generate_namespace {
    my ($encompasser, $controller, $adhoc_digest) = @_;
    return join '::',
        $encompasser, '_complexed', $controller, $adhoc_digest ? $adhoc_digest : ();
}

sub _generate_complex {
    my ($encompasser, $controller, $adhoc_digest) = @_;
    my $complex = \%COMPLEX;
    for ($encompasser, $controller, $adhoc_digest || '_') {
        $complex = $complex->{$_} ||= {};
    }
    return if 0 < keys %{$complex};
    return $complex;
}

sub _conflate {
    my ($complex, $encompasser, $controller, $adhoc) = @_;
    for my $class ($controller, @{$adhoc}) {
        Encomp::Util::load_class($class);
    }
    my $plugins_c = $controller ->composite->seek_all_plugins;
    my $plugins_e = $encompasser->composite->seek_all_plugins;
    my @args      = (
        $complex,
        $plugins_c, $controller,
        $plugins_e, $encompasser,
        $adhoc,
    );
    _conflate_methods(@args);
    _conflate_hooks  (@args);
    _conflate_any    (@args);
    return 1;
}

sub _conflate_methods {
    my ($complex, $plugins_c, $controller, $plugins_e, $encompasser, $adhoc) = @_;
    # $e doesn't target.
    my @classes = (@{$plugins_c}, $controller, @{$plugins_e}, @{$adhoc});
    my %methods;
    for my $class (uniq @classes) {
        my $entries = do { no strict 'refs'; \%{$class . '::'} };
        %methods = (%methods, %{$entries});
    }
    delete $methods{$_}
        for qw/__ANON__ ISA BEGIN can isa/, grep /^_/, keys %methods;
    map { /::$/o && delete $methods{$_} } keys %methods;
    $complex->{methods} = \%methods;
}

sub _conflate_hooks {
    my ($complex, $plugins_c, $controller, $plugins_e, $encompasser, $adhoc) = @_;
    my @classes = (@{$plugins_c}, $controller, @{$plugins_e}, $encompasser, @{$adhoc});
    my %hooks;
    for my $class (uniq @classes) {
        my $hooks = $class->composite->hooks;
        for my $point (keys %{$hooks}) {
            push @{$hooks{$point} ||= []}, @{$hooks->{$point}};
        }
    }
    $complex->{hooks} = \%hooks;
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

1;

__END__
