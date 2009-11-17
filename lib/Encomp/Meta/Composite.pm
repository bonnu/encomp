package Encomp::Meta::Composite;

use strict;
use warnings;
use Encomp::Util;

sub new {
    my $class = shift;
    bless {
        hooks      => {},
        plugins    => [],
        properties => [],
    }, $class;
}

sub hooks      { $_[0]->{hooks} }
sub plugins    { $_[0]->{plugins} }
sub properties { $_[0]->{properties} }

sub seek_all_plugins {
    my ($self, $plugins) = @_;
    $plugins ||= [];
    for my $plugin (@{$self->plugins}) {
        unless (grep { $_ eq $plugin } @{$plugins}) {
            push @{$plugins}, $plugin;
            $plugin->composite->seek_all_plugins($plugins);
        }
    }
    $plugins;
}

sub add_hook {
    my ($self, $hook, $callback) = @_;
    push @{$self->hooks->{$hook} ||= []}, $callback;
}

sub add_plugins {
    my ($self, @plugins) = @_;
    Encomp::Util::load_class($_) for @plugins;
    push @{$self->plugins}, @plugins;
}

sub add_property {
    my ($self, $name, $code) = @_;
    push @{$self->properties}, { name => $name, code => $code };
}

1;

__END__
