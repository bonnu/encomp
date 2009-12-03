package Encomp::Class;

use strict;
use warnings;
use Data::Util ();

use constant _strict_bits => strict::bits(qw/subs refs vars/);

my %METADATA;

sub import {
    $^H             |= _strict_bits;         # strict->import;
    ${^WARNING_BITS} = $warnings::Bits{all}; # warnings->import;
}

sub setup_metadata {
    my $class  = shift;
    my $caller = scalar caller;
    $class->register_metadata($caller, @_);
}

sub register_metadata {
    my ($class, $applicant, @args) = @_;
    my $setup = $METADATA{$applicant} ||= [];
    while (my ($key, $func) = splice @args, 0, 2) {
        push @{$setup}, { name => $key, func => $func };
    }
}

sub install_metadata {
    my ($class, $applicant, $setuped) = @_;
    my $setup = $METADATA{$setuped} or return;
    for my $metadata (@{$setup}) {
        my $data = $metadata->{func}->($applicant);
        do {
            no strict 'refs';
            *{"$applicant\::$metadata->{name}"} = sub { $data };
        };
    }
}

sub reinstall_subroutine {
    my ($class, $applicant, @args) = @_;
    no warnings 'redefine';
    Data::Util::install_subroutine($applicant, @args);
}

sub uninstall_subroutine {
    my ($class, $applicant, @args) = @_;
    Data::Util::uninstall_subroutine($applicant, @args);
}

1;

__END__
