package Encomp::Specific::PluginConfig;

use Encomp::Exporter;
use base qw/Encomp::Specific::Plugin/;

# know Encomp::Specific::Config

Encomp::Exporter->setup_suger_features(
    setup => sub {
        my $complex = shift;
        for my $plugin (@{$complex->{loaded}}) {
#           $plugin->
        }
    },
);

1;

__END__
