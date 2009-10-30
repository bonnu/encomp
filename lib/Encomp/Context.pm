package Encomp::Context;

use strict;
use warnings;
use Carp qw/croak/;

sub new {
    my $class = shift;
    my $self  = bless {
        return  => 0,
        skip    => 0,
        errors  => [],
        current => undef,
        _goto   => undef,
    }, $class;
    return $self;
}

sub return { 1 < scalar @_ ? ($_[0]->{return} = $_[1]) : $_[0]->{return} }
sub skip   { 1 < scalar @_ ? ($_[0]->{skip} = $_[1]) : $_[0]->{skip} }
sub errors { $_[0]->{errors} }
sub _goto  { $_[0]->{_goto} }

sub current {
    my ($self, $hook) = @_;
    return $self->{current} unless $hook;
    $self->{current} = $hook;
    return unless $self->{skip};
    if ($hook eq $self->{_goto}) {
        $self->skip(0);
        $self->clear_goto;
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

sub clear_goto    { undef $_[0]->{_goto} }
sub error_number  { scalar @{ $_[0]->errors } }
sub has_error     { scalar @{ $_[0]->errors } ? 1 : 0 }
sub add_errors    { push @{ shift->errors } => @_ }
sub clear_errors  { @{ $_[0]->errors } = () }

1;

__END__
