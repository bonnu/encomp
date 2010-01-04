package Encomp::Specific::Hook;

use Encomp::Exporter;
use base qw/Encomp::Base/;

Encomp::Exporter->setup_suger_features(
    as_is => [qw/hook_to/],
    setup => sub {
        my $complex = shift;
        my %hooks;
        for my $class (@{$complex->{loaded}}) {
            my $hooks = $class->composite->hooks;
            for my $point (keys %{$hooks}) {
                push @{$hooks{$point} ||= []}, @{$hooks->{$point}};
            }
        }
        $complex->{hooks} = \%hooks;
    },
);

sub hook_to {
    my $class = caller;
    $class->composite->add_hook(@_);
}

1;

__END__
