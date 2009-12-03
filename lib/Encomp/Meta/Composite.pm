package Encomp::Meta::Composite;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use Encomp::Util;
use List::MoreUtils qw/uniq/;
use Sub::Name qw/subname/;

__PACKAGE__->mk_accessors qw/applicant hooks plugins _sought_plugins/;

sub new {
    my ($class, $applicant) = @_;
    $class->SUPER::new({
        applicant       => $applicant,
        hooks           => {},
        plugins         => [],
        _sought_plugins => undef,
    });
}

sub seek_all_plugins {
    my ($self, $loaded) = @_;
    $loaded ||= [];
    if (my $sought = $self->_sought_plugins) {
        @{$loaded} = uniq @{$loaded}, @{$sought};
    }
    else {
        $self->_seek_all_plugins($loaded);
        $self->_sought_plugins([@{$loaded}]);
    }
    return $loaded;
}

sub _seek_all_plugins {
    my ($self, $loaded) = @_;
    $loaded ||= [];
    for my $plugin (@{$self->plugins}) {
        next if grep { $_ eq $plugin } @{$loaded};
        $plugin->composite->seek_all_plugins($loaded);
        next if grep { $_ eq $plugin } @{$loaded};
        push @{$loaded}, $plugin;
    }
    return $loaded;
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
    return $self->_sought_plugins([@{$self->_seek_all_plugins}]);
}

1;

__END__
