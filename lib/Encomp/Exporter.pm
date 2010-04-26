package Encomp::Exporter;

use Encomp::Util;
use base qw/Exporter/;
use Encomp::Exporter::Spec;
use Carp qw/croak/;

our @EXPORT = qw/setup_suger_features/;

sub import {
    my ($class) = @_;
    $^H             |= Encomp::Util::strict_bits; # strict->import;
    ${^WARNING_BITS} = $warnings::Bits{all};      # warnings->import;
    $class->export_to_level(1, @_);
}

sub setup_suger_features {
    my $caller = caller;
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
