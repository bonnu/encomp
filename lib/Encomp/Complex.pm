package Encomp::Complex;

use Encomp::Class;
use Encomp::Util;
use Carp qw/croak confess/;
use Digest::MD5 qw/md5_hex/;
use List::MoreUtils qw/uniq/;
use UNIVERSAL::can;

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
        Encomp::Class->reinstall_subroutine(
            $namespace,
            AUTOLOAD => \&_autoload,
            can      => \&_can,
            complex  => sub { $complex },
        );
    }
    return $namespace;
}

sub _initial_args {
    my ($encompasser, $controller) = @_;
    my @adhoc;
    confess 'controller name is required.' unless $controller;
    if (ref $controller eq 'ARRAY') {
        @adhoc      = @{$controller};
        $controller = shift @adhoc;
    }
    return ($encompasser, $controller, \@adhoc);
}

sub _generate_adhoc_digest {
    my $adhoc = shift;
    my $digest;
    if (0 < @{$adhoc}) {
        $digest = '_' . md5_hex(join '', sort @{$adhoc});
    }
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
    my @classes   = uniq(
        @{ $plugins_c }, $controller,
        @{ $plugins_e }, $encompasser,
        @{ $adhoc     },
    );
    _conflate_methods($complex, @classes);
    _conflate_hooks  ($complex, @classes);
    return 1;
}

sub _conflate_methods {
    my ($complex, @classes) = @_;
    my %methods;
    for my $class (@classes) {
        my $entries = Data::Util::get_stash($class);
        %methods = (%methods, %{$entries});
    }
    delete $methods{$_} for
        qw/__ANON__ ISA BEGIN CHECK INIT END AUTOLOAD DESTROY/,
        qw/can isa import unimport/,
        qw/composite/,
        grep /^_/, keys %methods;
    map { /(^EXPORT.*|::$)/o && delete $methods{$_} } keys %methods;
    $complex->{methods} = \%methods;
}

sub _conflate_hooks {
    my ($complex, @classes) = @_;
    my %hooks;
    for my $class (@classes) {
        my $hooks = $class->composite->hooks;
        for my $point (keys %{$hooks}) {
            push @{$hooks{$point} ||= []}, @{$hooks->{$point}};
        }
    }
    $complex->{hooks} = \%hooks;
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
    $_[0]->complex->{methods}{$_[1]} || do { no warnings; UNIVERSAL::can(@_) }
}

1;

__END__
