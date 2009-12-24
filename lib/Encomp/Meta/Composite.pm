package Encomp::Meta::Composite;

use Encomp::Util;
use base qw/Class::Accessor::Fast/;
use List::MoreUtils qw/uniq/;
use Sub::Name qw/subname/;

__PACKAGE__->mk_accessors qw/
    applicant
    depending_plugins
    hooks
    plugins
    plugout
    stash
/;

sub new {
    my ($class, $applicant) = @_;
    my $self = $class->SUPER::new({
        applicant         => $applicant,
        depending_plugins => undef,
        hooks             => {},
        plugins           => [],
        plugout           => [],
        stash             => {},
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
    my @added;
    for my $plugin (uniq @plugins) {
        next if grep { $_ eq $plugin } @{$self->plugins};
        Encomp::Util::load_class($plugin);
        push @{$self->plugins}, $plugin;
        push @added, $plugin;
    }
    $self->_delete_elements_inc_in_list($self->plugout, \@added);
}

sub add_plugout {
    my ($self, @plugout) = @_;
    my @added;
    for my $plugout (uniq @plugout) {
        next if grep { $_ eq $plugout } @{$self->plugout};
        push @{$self->plugout}, $plugout;
        push @added, $plugout;
    }
    $self->_delete_elements_inc_in_list($self->plugins, \@added);
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
    if (my $ret = $self->depending_plugins) {
        @plugins = @{$ret};
    }
    else {
        for my $plugin (@{$self->plugins}) {
            next if grep { $_ eq $plugin } @plugins;
            $plugin->composite->compile_depending_plugins(\@plugins);
        }
        @plugins = uniq @plugins, $self->applicant; # add self
        $self->_delete_elements_inc_in_list(\@plugins, $self->plugout);
        $self->depending_plugins(\@plugins);
    }
    if (0 < @_ && ref $_[0] eq 'ARRAY') {
        push @{$_[0]}, @plugins;
    }
}

sub _delete_elements_inc_in_list {
    my ($self, $list, $del_list) = @_;
    $del_list = [ $del_list ] unless ref $del_list && ref $del_list eq 'ARRAY';
    for (my $i = 0; $i < @{$list};) {
        if (grep { $_ eq $list->[$i] } @{$del_list}) {
            splice @{$list}, $i, 1;
        }
        else {
            $i++;
        }
    }
}

1;

__END__

=head1 NAME

Encomp::Meta::Composite

=head1 SYNOPSIS

 my $composite = Encomp::Meta::Composite->new($owner_class);

=head1 DESCRIPTION

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
