package Encomp::Base;

use Encomp::Exporter;
use Encomp::Meta::Composite;
use Encomp::Util;
use List::MoreUtils qw/uniq/;

Encomp::Exporter->setup_suger_features(
    metadata => { composite => sub { Encomp::Meta::Composite->new(@_) } },
);

sub conflate {
    my ($class, @classes) = @_;
    my $complex = {};
    my @loaded;
    for my $plugin (@classes) {
        Encomp::Util::load_class($plugin);
        $plugin->composite->compile_depending_plugins;
        push @loaded, @{$plugin->composite->depending_plugins};
    }
    @loaded = uniq @loaded;
    my @exporters;
    for my $plugin (@loaded) {
        push @exporters, Encomp::Exporter->get_coated_base_exporters($plugin);
    }
    @exporters = uniq @exporters;
    $complex->{loaded}    = \@loaded;
    $complex->{exporters} = \@exporters;
    for my $exporter (@exporters) {
        map { $_->($complex) } Encomp::Exporter->get_setup_methods($exporter);
    }
    return $complex;
}

1;

__END__
