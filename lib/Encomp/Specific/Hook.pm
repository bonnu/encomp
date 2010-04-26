package Encomp::Specific::Hook;

use Encomp::Exporter;
use base qw/Encomp::Base/;

setup_suger_features
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
;

suger_feature hook_to => sub {
    my $class = shift;
    $class->composite->add_hook(@_);
};

1;

__END__
