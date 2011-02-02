package Encomp::Context;

use strict;
use warnings;
use parent qw/Class::Accessor::Fast/;
use Carp qw/croak/;

__PACKAGE__->mk_accessors qw/return skip _goto/;

sub new {
    my $class = shift;
    $class->SUPER::new({
        return  => 0,
        skip    => 0,
        current => undef,
        _goto   => undef,
    });
}

sub current {
    my ($self, $hook) = @_;
    if ($hook) {
        $self->{current} = $hook;
        return unless $self->{skip};
        if ($hook eq $self->{_goto}) {
            $self->clear_goto;
        }
    }
    else {
        return $self->{current};
    }
}

sub goto {
    my ($self, $path) = @_;
    if ($path) {
        $self->current
            || croak 'current position is not set.';
        my $hook = $self->current->find_by_path($path)
            || croak "specified path doesn't exist: $path";
        $self->_goto($hook);
        $self->skip(1);
    }
    else {
        $self->_goto;
    }
}

sub clear_goto {
    my $self = shift;
    $self->_goto(undef);
    $self->skip(0);
}

1;

__END__
