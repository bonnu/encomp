package Encomp::Meta::Composite;

use strict;
use warnings;
use Encomp::Util;

sub new {
    my $class = shift;
    bless {
        hook    => {},
        plugins => [],
    }, $class;
}

sub hook    { $_[0]->{hook} }
sub plugins { $_[0]->{plugins} }

sub seek_all_plugins {
    my ($self, $plugins) = @_;
    $plugins ||= [];
    for my $plugin (@{$self->plugins}) {
        unless (grep { $_ eq $plugin } @{$plugins}) {
            Encomp::Util->load_class($plugin);
            push @{$plugins}, $plugin;
            $plugin->composite->seek_all_plugins($plugins);
        }
    }
    $plugins;
}

sub add_hook {
    my ($self, $hook, $callback) = @_;
    push @{$self->hook->{$hook} ||= []}, $callback;
}

sub add_plugins {
    my ($self, @plugins) = @_;
    push @{$self->plugins}, @plugins;
}

1;

__END__
