package Encomp::Meta::Composite;

use Encomp::Util;
use parent qw/Class::Accessor::Fast/;
use List::MoreUtils qw/uniq/;
use List::Compare::Functional;

__PACKAGE__->mk_accessors qw/
    applicant
    depending_plugins
    hooks
    plugins
    plugout
    stash
    _current_loaded
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
    my @plugins = @{$self->load_depending_plugins};
    for my $plugin (reverse @plugins) {
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
    _delete_elements_inc_in_list($self->plugout, \@added);
}

sub add_plugout {
    my ($self, @plugout) = @_;
    my @added;
    for my $plugout (uniq @plugout) {
        next if grep { $_ eq $plugout } @{$self->plugout};
        push @{$self->plugout}, $plugout;
        push @added, $plugout;
    }
    _delete_elements_inc_in_list($self->plugins, \@added);
}

sub add_hook {
    my ($self, $hook, $callback) = @_;
    my $hooks  = $self->hooks->{$hook} ||= [];
    my $number = int @{$hooks};
    $hook =~ s!/!_!go;
    my $name     = "$hook\_$number";
    my $fullname = $self->applicant . "::$name";
    Encomp::Util::reinstall_subroutine($self->applicant, $name => $callback);
    push @{$hooks}, do { no strict 'refs'; *{$fullname} };
}

sub compile_depending_plugins {
    my $self = shift;
    my @plugins;
    if (my $ret = $self->depending_plugins) {
        @plugins = @{$ret};
    }
    else {
        @plugins = @{$self->load_depending_plugins};
        $self->depending_plugins(\@plugins);
    }
    if (0 < @_ && ref $_[0] eq 'ARRAY') {
        push @{$_[0]}, @plugins;
    }
}

sub load_depending_plugins {
    my $self = shift;
    my @plugins;
    for my $plugin (@{$self->plugins}) {
        next if grep { $_ eq $plugin } @plugins;
        $plugin->composite->compile_depending_plugins(\@plugins);
    }
    @plugins = uniq @plugins, $self->applicant; # add self
    _delete_elements_inc_in_list(\@plugins, $self->plugout);
    return \@plugins;
}

sub _delete_elements_inc_in_list {
    my ($list, $del_list) = @_;
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
