package Encomp::Complex;

use Encomp::Util;
use Encomp::Exporter;
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

sub _initialize {
    my ($encompasser, $controller, $adhoc) = _initial_args(@_);
    my $id        = 0 < @{$adhoc} ? '_' . md5_hex join '', sort @{$adhoc} : '_';
    my $namespace = _generate_namespace($encompasser, $controller, $id);
    my $complex   = _initialize_complex($encompasser, $controller, $id);
    if ($complex) {
        _conflate($complex, $encompasser, $controller, $adhoc);
        Encomp::Util::reinstall_subroutine(
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

sub _generate_namespace {
    my ($encompasser, $controller, $id) = @_;
    return join '::',
        $encompasser, '_complexed', $controller, $id;
}

sub _initialize_complex {
    my ($encompasser, $controller, $id) = @_;
    my $complex = \%COMPLEX;
    for my $namespace ($encompasser, $controller, $id) {
        $complex = $complex->{$namespace} ||= {};
    }
    return if 0 < keys %{$complex};
    return $complex;
}

sub _conflate {
    my ($complex, $encompasser, $controller, $adhoc) = @_;
    my @classes;
    my @exporters;
    for my $class (uniq $controller, $encompasser, @{$adhoc}) {
        Encomp::Util::load_class($class);
        $class->composite->compile_depending_plugins;
        push @classes,   @{$class->composite->depending_plugins};
        push @exporters, Encomp::Exporter->get_coated_base_classes($class);
    }
    @classes   = uniq @classes;
    @exporters = uniq @exporters;
    for my $exporter (@exporters) {
        map { $_->($complex, @classes) }
            Encomp::Exporter->get_setup_methods($exporter);
    }
    return 1;
}

sub _autoload {
    my $proto = $_[0];
    my $name  = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    my $ns = $1;
    if (my $symbol = $proto->complex->{methods}{$name}) {
        Encomp::Util::reinstall_subroutine($ns, $name => \&{$symbol});
        goto \&{$symbol};
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

sub _can {
    $_[0]->complex->{methods}{$_[1]} || do { no warnings; UNIVERSAL::can(@_) }
}

1;

__END__

=h1 NAME

Encomp::Complex

=h1 DESCRIPTION

The class group composed of mechanism of Encomp is synthesized.

=h1 SYNOPSIS

 my $creature = Encomp::Complex->build($design_class, $controller_class);

=h1

=cut
