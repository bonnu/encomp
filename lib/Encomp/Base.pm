package Encomp::Base;

use Encomp::Exporter;
use Encomp::Meta::Composite;
use Carp qw/croak/;

Encomp::Exporter->setup_suger_features(
    as_is    => [qw/hook_to plugins AUTOLOAD/],
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
    my $proto = shift;
    my $name  = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    # TODO: error
    if (my $code = $proto->composite->get_code($name)) {
        return wantarray ? ($code->($proto, @_)) : $code->($proto, @_);
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

1;

__END__