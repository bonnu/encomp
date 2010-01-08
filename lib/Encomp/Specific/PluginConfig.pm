package Encomp::Specific::PluginConfig;

use Encomp::Exporter;
use base qw/Encomp::Base/;

Encomp::Exporter->setup_suger_features(
    setup => sub {
        my $complex = shift;
        for my $plugin (@{$complex->{loaded}}) {
        }
    },
);

1;

__END__
