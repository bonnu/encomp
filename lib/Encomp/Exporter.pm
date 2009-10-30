package Encomp::Exporter;

use strict;
use warnings;
use Carp qw/croak/;

use Encomp::Class;
use Encomp::Util;

my %SPEC;

use constant _strict_bits => strict::bits(qw/subs refs vars/);

sub import {
    $^H             |= _strict_bits;         # strict->import;
    ${^WARNING_BITS} = $warnings::Bits{all}; # warnings->import;
}

sub setup_suger_features {
    my $class  = shift;
    my $caller = scalar caller;
    croak 'This function should not be called from main' if $caller eq 'main';
    $class->_build_spec($caller, @_);
    my $super  = do { no strict 'refs'; \@{$caller . '::ISA'} };
    my $base   = 'Exporter';
    push @{$super}, $base unless grep m!\A$base\Z!, @{$super};
    do {
        no strict 'refs';
        *{$caller . '::import'}   = $class->_build_import($caller);
        *{$caller . '::unimport'} = $class->_build_unimport($caller);
        @{$caller . '::EXPORT'}   = $class->_build_export($caller);
    };
}

sub _build_spec {
    my ($class, $promoter, %args) = @_;
    return if exists $SPEC{$promoter};
    if (my $load_class = $SPEC{$promoter}{applicant_isa} = $args{applicant_isa}) {
        Encomp::Util::load_class($load_class);
    }
    $SPEC{$promoter}{setup}    = $args{setup};
    $SPEC{$promoter}{as_is}    = $args{as_is} || [];
    $SPEC{$promoter}{metadata} = $args{metadata} || undef;
}

sub _build_import {
    my ($class, $promoter) = @_;
    sub {
        $^H             |= _strict_bits;         # strict->import;
        ${^WARNING_BITS} = $warnings::Bits{all}; # warnings->import;
        my $class  = shift;
        my $caller = scalar caller;
        return if $class  ne $promoter;
        return if $caller eq 'main';
        my $isa    = do { no strict 'refs'; \@{$caller . '::ISA'} };
        for my $super (reverse @{Encomp::Util::get_linear_isa($class)}) {
            my ($base, $metadata, $setup) = @{$SPEC{$super}}{qw/applicant_isa metadata setup/};
            if ($base) {
                unshift @{$isa}, $base unless grep m!\A$base\Z!, @{$isa};
                Encomp::Class->install_metadata($caller, $base);
            }
            $super->export_to_level(1, $super);
            if ($metadata && ref $metadata eq 'HASH') {
                for my $name (keys %{$metadata}) {
                    my $data = $metadata->{$name}->($class, $caller) or next;
                    do {
                        no strict 'refs';
                        *{"$caller\::$name"} = sub { $data };
                    };
                }
            }
            if ($setup && ref $setup eq 'CODE') {
                $setup->($class, $caller);
            }
        }
    }
}

sub _build_unimport {
    my ($class, $promoter) = @_;
    sub {
        my $class  = shift;
        my $caller = scalar caller;
        my $stash  = do { no strict 'refs'; \%{$caller . '::'} };
        for my $isa (@{ Encomp::Util::get_linear_isa($class) }) {
            my $export = do { no strict 'refs'; \@{$isa . '::EXPORT'} };
            delete $stash->{$_} for @{$export};
        }
    }
}

sub _build_export {
    my ($class, $promoter) = @_;
    @{$SPEC{$promoter}{as_is}};
}

1;

__END__
