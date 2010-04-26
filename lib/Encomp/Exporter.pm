package Encomp::Exporter;

use Encomp::Util;
use Encomp::Exporter::Spec;
use Carp qw/croak/;

sub import {
    $^H             |= Encomp::Util::strict_bits; # strict->import;
    ${^WARNING_BITS} = $warnings::Bits{all};      # warnings->import;
}

sub setup_suger_features {
    my $class  = shift;
    my $caller = scalar caller;
    croak 'This function should not be called from main' if $caller eq 'main';
    Encomp::Exporter::Spec::build_spec($caller, @_);
    Encomp::Util::reinstall_subroutine(
        $caller,
        import   => Encomp::Exporter::Spec::build_import  ($caller),
        unimport => Encomp::Exporter::Spec::build_unimport($caller),
    );
}

1;

__END__
