package Encomp::Specific::DuckType;

use Encomp::Exporter;

Encomp::Exporter->setup_suger_features(
    as_is => [qw/duck_type/],
    
);

sub duck_type {
    my $class = caller;
}

1;

__END__
