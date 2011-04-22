package Encomp::Specific::ProcessModifier;

use Encomp::Exporter;
use parent qw/Encomp::Base/;
use Carp qw/croak confess/;

setup_sugar_features
    as_is => [qw/modify_process/],
    setup => sub {
        my $complex   = shift;
        my $modifiers = $complex->{process_modifiers} = [];
        for my $class (@{$complex->{loaded}}) {
            my $stash = $class->composite->stash->{process_modifiers};
            next unless $stash;
            push @{ $modifiers }, @{$stash};
        }
    },
;

sugar_feature modify_process => sub {
    my $class = shift;
    my $stash = $class->composite->stash->{process_modifiers} ||= [];
    while (my ($type, $modifier) = splice @_, 0, 2) {
        push @{$stash}, { type => $type, modifier => $modifier };
    }
};

1;

__END__
