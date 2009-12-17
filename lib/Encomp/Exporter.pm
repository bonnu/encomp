package Encomp::Exporter;

use Encomp::Class;
use Encomp::Util;
use Carp qw/croak/;
use List::MoreUtils qw/uniq/;

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
    Encomp::Util::reinstall_subroutine(
        $caller,
        import   => $class->_build_import  ($caller),
        unimport => $class->_build_unimport($caller),
    );
}

sub _build_spec {
    my ($class, $promoter, %args) = @_;
    return if exists $SPEC{$promoter};
    my $spec = $SPEC{$promoter} = {};
    if (my $load_class = $spec->{applicant_isa} = $args{applicant_isa}) {
        Encomp::Util::load_class($load_class);
    }
    my @unimport;
    my $as_is = $args{as_is} || [];
    for (@{$as_is}) {
        s/^([+])//;
        push @unimport, $_ unless $1 && $1 eq '+';
    }
    my $with = $args{specific_with} || [];
    $with = [ $with ] unless ref $with eq 'ARRAY';
    $spec->{as_is}         = $as_is;
    $spec->{_unimport}     = \@unimport;
    $spec->{setup}         = $args{setup};
    $spec->{metadata}      = $args{metadata}    || undef;
    $spec->{specific_ns}   = $args{specific_ns} || $promoter;
    $spec->{specific_with} = $with;
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
        my $isa    = do { no strict 'refs'; \@{$caller . '::ISA'} };
        my @loaded = _get_dependent_addons($class);
        for my $addon (_load_addons($class, @addons)) {
            push @loaded, _get_dependent_addons($addon);
        }
        @loaded = uniq @loaded;
        for my $super (@loaded) {
            my ($base, $metadata, $setup, $as_is) =
                @{$SPEC{$super}}{qw/applicant_isa metadata setup as_is/};
            if ($base) {
                unshift @{$isa}, $base unless grep m!\A$base\Z!, @{$isa};
                Encomp::Class::install_metadata($caller, $base);
            }
            if (0 < @{$as_is}) {
                no strict 'refs';
                Encomp::Util::reinstall_subroutine(
                    $caller, 
                    map { $_ => \&{"${super}::${_}"} } @{$as_is},
                );
            }
            if ($metadata && ref $metadata eq 'HASH') {
                my %methods;
                for my $name (keys %{$metadata}) {
                    my $data = $metadata->{$name}->($caller) or next;
                    $methods{$name} = sub { $data };
                }
                Encomp::Util::reinstall_subroutine($caller, \%methods);
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
        my @addons = @{$ADDED{$class}{$caller}};
        for my $super (reverse @addons) {
            my $unimport = $SPEC{$super}{_unimport};
            Encomp::Util::uninstall_subroutine($caller, @{$unimport});
        }
        return 1;
    }
}

sub _get_dependent_addons {
    my $class = shift;
    my @isa   = reverse @{Encomp::Util::get_linear_isa($class)};
    my @addons;
    for my $super (@isa) {
        my $with = $SPEC{$super}{specific_with};
        for my $addon (_load_addons($super, @{$with})) {
            push @addons, _get_dependent_addons($addon);
        }
        push @addons, $super;
    }
    return uniq @addons, $class;
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
