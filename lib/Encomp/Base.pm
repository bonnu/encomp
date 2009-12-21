package Encomp::Base;

use Encomp::Exporter;
use Encomp::Meta::Composite;

Encomp::Exporter->setup_suger_features(
    metadata => { composite => sub { Encomp::Meta::Composite->new(@_) } },
);

1;

__END__
