package Encomp::Util;

use strict;
use warnings;
use Carp qw/confess/;
use Data::Util qw/:all/;

use constant _strict_bits => strict::bits(qw/subs refs vars/);

sub import {
    $^H             |= _strict_bits;         # strict->import;
    ${^WARNING_BITS} = $warnings::Bits{all}; # warnings->import;
}

# code was stolen from Mouse::Util orz
BEGIN {
    my $impl;
    if ($] >= 5.009_005) {
        require mro;
        $impl = \&mro::get_linear_isa;
    } else {
        my $e = do {
            local $@;
            eval { require MRO::Compat };
            $@;
        };
        if (!$e) {
            $impl = \&mro::get_linear_isa;
        } else {
#       VVVVV   CODE TAKEN FROM MRO::COMPAT   VVVVV
            my $_get_linear_isa_dfs; # this recurses so it isn't pretty
            $_get_linear_isa_dfs = sub {
                no strict 'refs';

                my $classname = shift;

                my @lin = ($classname);
                my %stored;
                foreach my $parent (@{"$classname\::ISA"}) {
                    my $plin = $_get_linear_isa_dfs->($parent);
                    foreach  my $p(@$plin) {
                        next if exists $stored{$p};
                        push(@lin, $p);
                        $stored{$p} = 1;
                    }
                }
                return \@lin;
            };
#       ^^^^^   CODE TAKEN FROM MRO::COMPAT   ^^^^^
            $impl = $_get_linear_isa_dfs;
        }
    }

    no warnings 'once';
    *get_linear_isa = $impl;
}

# taken from Class/MOP.pm
sub is_valid_class_name {
    my $class = shift;

    return 0 if ref($class);
    return 0 unless defined($class);

    return 1 if $class =~ /^\w+(?:::\w+)*$/;

    return 0;
}

# taken from Class/MOP.pm
my %is_class_loaded_cache;
sub _try_load_one_class {
    my $class = shift;

    unless ( is_valid_class_name($class) ) {
        my $display = defined($class) ? $class : 'undef';
        confess "Invalid class name ($display)";
    }

    return undef if $is_class_loaded_cache{$class} ||= is_class_loaded($class);

    my $file = $class . '.pm';
    $file =~ s{::}{/}g;

    return do {
        local $@;
        eval { require($file) };
        $@;
    };
}

# taken from Mouse/Util.pm
sub load_class {
    my $class = shift;
    my $e = _try_load_one_class($class);
    confess "Could not load class ($class) because : $e" if $e;

    return 1;
}

# taken from Mouse/Util.pm
sub is_class_loaded {
    my $class = shift;

    return 0 if ref($class) || !defined($class) || !length($class);

    # walk the symbol table tree to avoid autovififying
    # \*{${main::}{"Foo::"}} == \*main::Foo::

    my $pack = \%::;
    foreach my $part (split('::', $class)) {
        my $entry = \$pack->{$part . '::'};
        return 0 if ref($entry) ne 'GLOB';
        $pack = *{$entry}{HASH} or return 0;
    }

    # check for $VERSION or @ISA
    return 1 if exists $pack->{VERSION}
             && defined *{$pack->{VERSION}}{SCALAR} && defined ${ $pack->{VERSION} };
    return 1 if exists $pack->{ISA}
             && defined *{$pack->{ISA}}{ARRAY} && @{ $pack->{ISA} } != 0;

    # check for any method
    foreach my $name( keys %{$pack} ) {
        my $entry = \$pack->{$name};
        return 1 if ref($entry) ne 'GLOB' || defined *{$entry}{CODE};
    }

    # fail
    return 0;
}

sub reinstall_subroutine {
    no warnings 'redefine';
    install_subroutine(@_);
}

sub collect_public_symbols {
    my @classes = @_;
    my %symbols;
    for my $class (@classes) {
        my $stash = Encomp::Util::get_stash($class);
        @symbols{keys %{$stash}} = values %{$stash};
    }
    delete @symbols{
        qw/__ANON__ ISA BEGIN CHECK INIT END AUTOLOAD DESTROY/,
        qw/can isa import unimport/,
        (grep /^_/, keys %symbols),
        (grep /(?:^EXPORT.*|::$)/o, keys %symbols),
    };
    return \%symbols;
}

1;

__END__

=head1 NAME

Encomp::Util - Utility Class

=head1 SEE ALSO

Mouse::Util

=cut
