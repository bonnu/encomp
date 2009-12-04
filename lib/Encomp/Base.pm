package Encomp::Base;

use Encomp::Exporter;
use Encomp::Meta::Composite;
use Carp qw/croak/;

Encomp::Exporter->setup_suger_features(
    as_is    => [qw/hook_to plugins +AUTOLOAD/],
    metadata => { composite => sub { Encomp::Meta::Composite->new(@_) } },
);

sub hook_to {
    my $class = caller;
    $class->composite->add_hook(@_);
}

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
    if (my $code = $proto->composite->get_method($name)) {
        goto \&{$code};
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

1;

__END__
