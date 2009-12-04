package Encomp::Class;

use Encomp::Util;

my %METADATA;

sub import {
    goto \&Encomp::Util::import;
}

sub setup_metadata {
    my $class  = shift;
    my $caller = scalar caller;
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
