package Encomp::Specific::Plugin;

use Encomp::Exporter;
use parent qw/Encomp::Base/;
use Encomp::Util;
use Carp qw/croak/;

Encomp::Exporter->setup_suger_features(
    as_is => [qw/plugins +AUTOLOAD/],
    setup => sub {
        my ($complex, @classes) = @_;
        my %methods;
        for my $class (@classes) {
            my %stash = %{ Encomp::Util::get_stash($class) };
            @methods{keys %stash} = values %stash;
        }
        delete @methods{qw/
            __ANON__ ISA BEGIN CHECK INIT END AUTOLOAD DESTROY
            can isa import unimport
            composite
        /};
        delete $methods{$_} for grep /^_/, keys %methods;
        delete $methods{$_} for grep /(?:^EXPORT.*|::$)/o, keys %methods;
        $complex->{methods} = \%methods;
    },
);

sub plugins {
    my $class   = caller;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    my $loaded  = $class->composite->add_plugins(@plugins);
}

sub AUTOLOAD {
    my $proto = $_[0];
    my $name  = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    if (my $code = $proto->composite->get_method_of_plugin($name)) {
        goto \&{$code};
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

1;

__END__
