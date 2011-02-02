package Encomp::Class;

use Encomp::Util;
use parent q/Exporter/;

our @EXPORT = qw/setup_metadata/;

my %METADATA;

sub import {
    my ($class) = @_;
    $^H             |= Encomp::Util::strict_bits; # strict->import;
    ${^WARNING_BITS} = $warnings::Bits{all};      # warnings->import;
    $class->export_to_level(1, @_);
}

sub setup_metadata {
    my $caller = caller;
    register_metadata($caller, @_);
}

sub register_metadata {
    my ($applicant, @args) = @_;
    my $setup = $METADATA{$applicant} ||= [];
    while (my ($key, $func) = splice @args, 0, 2) {
        push @{$setup}, { name => $key, func => $func };
    }
}

sub install_metadata {
    my ($applicant, $setuped) = @_;
    my $setup = $METADATA{$setuped} or return;
    my %methods;
    for my $metadata (@{$setup}) {
        my $data = $metadata->{func}->($applicant);
        $methods{$metadata->{name}} = sub { $data };
    }
    Encomp::Util::reinstall_subroutine($applicant, \%methods);
}

1;

__END__
