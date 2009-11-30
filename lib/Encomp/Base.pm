package Encomp::Base;

use Encomp::Exporter;
use Encomp::Meta::Composite;

Encomp::Exporter->setup_suger_features(
    as_is    => [qw/hook_to plugins/],
    metadata => { composite => sub { Encomp::Meta::Composite->new(@_) } },
);

sub hook_to {
    my $class = caller;
    $class->composite->add_hook(@_);
}

sub plugins {
    my $class = caller;
    $class->composite->add_plugins(ref $_[0] ? @{$_[0]} : @_);
}

1;

__END__
