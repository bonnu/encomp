package Encomp::Specific::Plugin;

use Encomp::Exporter;
use base qw/Encomp::Base/;
use Carp qw/croak confess/;
use Encomp::Util;

setup_suger_features
    as_is => [qw/plugins plugout +AUTOLOAD/],
    setup => sub {
        my $complex = shift;
        my $methods = Encomp::Util::collect_public_methods(@{$complex->{loaded}});
        delete $methods->{composite};
        $complex->{methods} = $methods;
    },
;

suger_feature plugins => sub {
    my $class   = shift;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    $class->composite->add_plugins(@plugins);
};

suger_feature plugout => sub {
    my $class   = shift;
    my @plugins = ref $_[0] ? @{$_[0]} : @_;
    $class->composite->add_plugout(@plugins);
};

sub AUTOLOAD {
    my $proto = $_[0];
    my $name  = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    if (my $code = $proto->composite->get_method_of_plugin($name)) {
        goto $code;
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}


1;

__END__
