package Encomp::Specific::Plugin;

use Encomp::Exporter;
use base qw/Encomp::Base/;
use Carp qw/croak confess/;
use Encomp::Complex;
use Encomp::Util;

our $AUTOLOAD;

Encomp::Exporter->setup_suger_features(
    as_is => [qw/plugins plugout/],
    setup => sub {
        my $complex = shift;
        my $symbols = Encomp::Util::collect_public_symbols(@{$complex->{loaded}});
        delete $symbols->{composite};
        $complex->{methods} = $symbols;
    },
);

sub plugins {
    my $class   = caller;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    $class->composite->add_plugins(@plugins);
}

sub plugout {
    my $class   = caller;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    $class->composite->add_plugout(@plugins);
}

1;

__END__
