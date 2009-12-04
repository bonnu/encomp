package Encomp::Meta::Composite;

use Encomp::Util;
use base qw/Class::Accessor::Fast/;
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

sub add_plugins {
    my ($self, @plugins) = @_;
    Encomp::Util::load_class($_) for @plugins;
    push @{$self->plugins}, @plugins;
    $self->check_all_plugins;
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
        $self->check_all_plugins($plugins, $methods);
    }
    return $plugins;
}

sub check_all_plugins {
    my ($self, $plugins, $methods) = @_;
    $plugins ||= [];
    $methods ||= {};
    for my $plugin (@{$self->plugins}) {
        next if grep { $_ eq $plugin } @{$plugins};
        $plugin->composite->get_all_plugins($plugins, $methods);
        next if grep { $_ eq $plugin } @{$plugins};
        {
            push @{$plugins}, $plugin;
            my %stash = %{Encomp::Util::get_stash($plugin)};
            map { delete $stash{$_} } grep /::$/o, keys %stash;
            %{$methods} = (%{$methods}, %stash);
        }
    }
    $self->{_sought_plugins} = [ @{$plugins} ];
    $self->{_sought_methods} = { %{$methods} };
    return $plugins;
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

sub get_method {
    my ($self, $name) = @_;
    exists $self->{_sought_methods}{$name} ? $self->{_sought_methods}{$name} : undef;
}

1;

__END__
