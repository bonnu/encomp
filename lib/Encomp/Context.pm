package Encomp::Context;

use strict;
use warnings;
use Carp qw/croak/;
use Scalar::Util qw/weaken/;

use Class::Accessor::Lite rw => [qw/return skip _goto/];

sub new {
    my $class = shift;
    bless {
        return  => 0,
        skip    => 0,
        _goto   => undef,
        current => undef,
        stash   => undef,
    }, $class;
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

sub stash {
    my $self = shift;
    weaken($self->{stash} = shift) if 0 < @_;
    $self->{stash};
}

sub clear_stash {
    my $self = shift;
    undef $self->{stash};
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
