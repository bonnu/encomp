package Encomp::Specific::Plugin;

use Encomp::Exporter;
use base qw/Encomp::Base/;
use Encomp::Util;
use Carp qw/croak/;

Encomp::Exporter->setup_suger_features(
    as_is => [qw/plugins unplug +AUTOLOAD/],
    setup => sub {
        my $complex = shift;
        my %methods;
        for my $class (@{$complex->{classes}}) {
            my %stash = %{ Encomp::Util::get_stash($class) };
            @methods{keys %stash} = values %stash;
        }
        delete @methods{
            qw/
                __ANON__ ISA BEGIN CHECK INIT END AUTOLOAD DESTROY
                can isa import unimport composite
            /,
            (grep /^_/, keys %methods),
            (grep /(?:^EXPORT.*|::$)/o, keys %methods),
        };
        $complex->{methods} = \%methods;
    },
);

sub plugins {
    my $class   = caller;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    $class->composite->add_plugins(@plugins);
}

sub unplug {
    my $class   = caller;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    $class->composite->add_unplug(@plugins);
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
