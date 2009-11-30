package Encomp::Exporter;

use strict;
use warnings;
use Carp qw/croak/;

use Encomp::Class;
use Encomp::Util;

my %SPEC;
my %ADDED;

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
    $SPEC{$promoter}{setup}       = $args{setup};
    $SPEC{$promoter}{as_is}       = $args{as_is}       || [];
    $SPEC{$promoter}{metadata}    = $args{metadata}    || undef;
    $SPEC{$promoter}{specific_ns} = $args{specific_ns} || $promoter;
}

sub _build_import {
    my (undef, $promoter) = @_;
    sub {
        $^H             |= _strict_bits;         # strict->import;
        ${^WARNING_BITS} = $warnings::Bits{all}; # warnings->import;
        my ($class, @addons) = @_;
        my $caller = scalar caller;
        return if $class  ne $promoter;
        return if $caller eq 'main';
        my @loaded = _load_addons($class, @addons);
        my $isa    = do { no strict 'refs'; \@{$caller . '::ISA'} };
        for my $super (reverse(@{Encomp::Util::get_linear_isa($class)}), @loaded) {
            my ($base, $metadata, $setup) =
                @{$SPEC{$super}}{qw/applicant_isa metadata setup/};
            if ($base) {
                unshift @{$isa}, $base unless grep m!\A$base\Z!, @{$isa};
                Encomp::Class->install_metadata($caller, $base);
            }
            $super->export_to_level(1, $super);
            if ($metadata && ref $metadata eq 'HASH') {
                for my $name (keys %{$metadata}) {
                    my $data = $metadata->{$name}->($caller) or next;
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
        ${$ADDED{$class} ||= {}}{$caller} = \@loaded if 0 < @loaded;
    }
}

sub _build_unimport {
    my (undef, $promoter) = @_;
    sub {
        my $class  = shift;
        my $caller = scalar caller;
        my $stash  = do { no strict 'refs'; \%{$caller . '::'} };
        my @addons = exists $ADDED{$class}{$caller} ? @{$ADDED{$class}{$caller}} : ();
        for my $super (reverse(@addons), @{Encomp::Util::get_linear_isa($class)}) {
            my $export = do { no strict 'refs'; \@{$super . '::EXPORT'} };
            delete $stash->{$_} for @{$export};
        }
        return 1;
    }
}

sub _build_export {
    my ($class, $promoter) = @_;
    @{$SPEC{$promoter}{as_is}};
}

sub _load_addons {
    my ($class, @addons) = @_;
    my @loaded;
    my $namespace = $SPEC{$class}{specific_ns};
    for my $addon (@addons) {
        $addon =~ s/^\+/$namespace\::/;
        push @loaded, $addon if Encomp::Util::load_class($addon);
    }
    return @loaded;
}

1;

__END__
