package Encomp::Meta::Composite;

use Encomp::Util;
use base qw/Class::Accessor::Fast/;
use List::MoreUtils qw/uniq/;
use Sub::Name qw/subname/;

__PACKAGE__->mk_accessors qw/
    applicant
    hooks
    plugins
    depending_plugins
/;

sub new {
    my ($class, $applicant) = @_;
    my $self = $class->SUPER::new({
        applicant         => $applicant,
        hooks             => {},
        plugins           => [],
        depending_plugins => undef,
    });
    return $self;
}

sub get_method_of_plugin {
    my ($self, $name) = @_;
    $self->compile_depending_plugins;
    for my $plugin (reverse @{$self->depending_plugins}) {
        my $code = $plugin->can($name) || next;
        return $code;
    }
}

sub add_plugins {
    my ($self, @plugins) = @_;
    for my $plugin (uniq @plugins) {
        next if grep { $_ eq $plugin } @{$self->plugins};
        Encomp::Util::load_class($plugin);
        push @{$self->plugins}, $plugin;
    }
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

sub compile_depending_plugins {
    my $self = shift;
    my @plugins;
    if ($self->depending_plugins) {
        @plugins = @{$self->depending_plugins};
    }
    else {
        for my $plugin (@{$self->plugins}) {
            next if grep { $_ eq $plugin } @plugins;
            $plugin->composite->compile_depending_plugins(\@plugins);
            push @plugins, $plugin;
        }
        @plugins = uniq @plugins;
        $self->depending_plugins(\@plugins);
    }
    if (@_ && ref $_[0] eq 'ARRAY') {
        push @{$_[0]}, @plugins;
    }
}

1;

__END__
