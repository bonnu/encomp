package Encomp::Meta::Composite;

use strict;
use warnings;
use Encomp::Util;

sub new {
    my ($class, $applicant) = @_;
    bless {
        applicant  => $applicant,
        hooks      => {},
        plugins    => [],
        properties => [],
    }, $class;
}

sub applicant  { $_[0]->{applicant} }
sub hooks      { $_[0]->{hooks} }
sub plugins    { $_[0]->{plugins} }
sub properties { $_[0]->{properties} }

=caller
sub seek_all_plugins {
    my ($self, $plugins, $callers) = @_;
    $plugins ||= [];
    $callers ||= [];
    push @{$callers}, $self->applicant;
    for my $plugin (@{$self->plugins}) {
        unless (
            grep { $_ eq $plugin } @{$plugins} ||
            grep { $_ eq $plugin } @{$callers}
        ) {
            $plugin->composite->seek_all_plugins($plugins, $callers);
            push @{$plugins}, $plugin;
        }
    }
    $plugins;
}
=cut

sub seek_all_plugins {
    my ($self, $plugins) = @_;
    $plugins ||= [];
    for my $plugin (@{$self->plugins}) {
        unless (grep { $_ eq $plugin } @{$plugins}) {
            $plugin->composite->seek_all_plugins($plugins);
            push @{$plugins}, $plugin;
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
