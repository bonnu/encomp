package Encomp::Meta::Composite;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use Encomp::Util;
use Data::Util qw/get_stash/;
use List::MoreUtils qw/uniq/;
use Sub::Name qw/subname/;

__PACKAGE__->mk_accessors qw/applicant hooks plugins/;

sub new {
    my ($class, $applicant) = @_;
    $class->SUPER::new({
        applicant       => $applicant,
        hooks           => {},
        plugins         => [],
        _sought_plugins => undef,
        _sought_methods => undef,
    });
}

sub get_all_plugins {
    my ($self, $plugins, $methods) = @_;
    $plugins ||= [];
    $methods ||= {};
    if (my $sought = $self->{_sought_plugins}) {
        @{$plugins} = uniq @{$plugins}, @{$sought};
        %{$methods} = (%{$methods}, %{$self->{_sought_methods}});
    }
    else {
        $self->_get_all_plugins($plugins, $methods);
        $self->{_sought_plugins} = +[ @{$plugins} ];
        $self->{_sought_methods} = +{ %{$methods} };
    }
    return ($plugins, $methods);
}

sub _get_all_plugins {
    my ($self, $plugins, $methods) = @_;
    $plugins ||= [];
    $methods ||= {};
    for my $plugin (@{$self->plugins}) {
        next if grep { $_ eq $plugin } @{$plugins};
        $plugin->composite->get_all_plugins($plugins, $methods);
        next if grep { $_ eq $plugin } @{$plugins};
        push @{$plugins}, $plugin;
        my %stash = %{get_stash($plugin)};
        map { delete $stash{$_} } grep /::$/o, keys %stash;
        %{$methods} = (%{$methods}, %stash);
    }
    return ($plugins, $methods);
}

sub add_hook {
    my ($self, $hook, $callback) = @_;
    my $hooks  = $self->hooks->{$hook} ||= [];
    my $number = int @{$hooks};
    $hook =~ s!/!_!go;
    my $fullname = $self->applicant . "::$hook\_$number";
    subname $fullname, $callback;
    push @{$hooks}, do {
        no strict 'refs';
        *{$fullname} = $callback;
    };
}

sub add_plugins {
    my ($self, @plugins) = @_;
    Encomp::Util::load_class($_) for @plugins;
    push @{$self->plugins}, @plugins;
    my ($plugins, $methods) = $self->_get_all_plugins;
    $self->{_sought_plugins} = +[ @{$plugins} ];
    $self->{_sought_methods} = +{ %{$methods} };
}

sub get_code {
    my ($self, $name) = @_;
    exists $self->{_sought_methods}{$name} ? $self->{_sought_methods}{$name} : undef;
}

1;

__END__
