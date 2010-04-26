package Encomp::Specific::DuckType;

use Encomp::Exporter;
use base qw/Encomp::Specific::Plugin/;
use Carp qw/confess/;

setup_suger_features
    as_is => [qw/duck_type/],
    setup => sub {
        my $complex = shift;
        my $methods = $complex->{methods};
        my %duck_type;
        for my $class (@{$complex->{loaded}}) {
            my $stash = $class->composite->stash->{duck_type};
            next unless $stash;
            for my $name (keys %{$stash}) {
                push @{$duck_type{$name} ||= []}, $stash->{$name};
            }
        }
        my $message = q{};
        for my $name (keys %duck_type) {
            unless (exists $methods->{$name}) {
                $message .= sprintf
                    qq{Requirement isn't met though "%s" duck_type is defined by these modules: %s\n},
                    $name, join ', ', @{$duck_type{$name}};
            }
        }
        $message && confess $message;
    },
;

suger_feature duck_type => sub {
    my $class = shift;
    my $stash = $class->composite->stash->{duck_type} ||= {};
    @{$stash}{@_} = map { $class } @_;
};

1;

__END__
