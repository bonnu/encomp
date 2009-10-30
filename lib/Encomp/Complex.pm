package Encomp::Complex;

use strict;
use warnings;
use Carp qw/croak/;

my %COMPLEX;

sub build {
    my $class = shift;
    my $ns    = $class->_conflate(@_);
    bless {}, $ns;
}

sub _conflate {
    my ($class, $encompasser, $controller) = @_;
    my $ns          = __generate_ns($encompasser, $controller);
    my $inside_hash = $COMPLEX{$encompasser} ||= {};
    unless (exists $inside_hash->{$controller}) {
        my $methods = __conflate_methods($encompasser, $controller);
        $inside_hash->{$controller} = { methods => $methods };
        do {
            no strict 'refs';
            *{$ns . '::AUTOLOAD'} = \&_autoload;
        };
    }
    return $ns;
}

sub __generate_ns {
    my ($encompasser, $controller) = @_;
    my $ns = join '::', $encompasser, '__complex__', $controller;
}

sub __split_ns {
    my $ns = shift;
    split '::__complex__::', $ns;
}

sub __conflate_methods {
    my ($encompasser, $controller) = @_;
    my %methods = do { no strict 'refs'; %{$controller . '::'} };
    for my $ignore (qw/__ANON__ ISA BEGIN/) {
        delete $methods{$ignore};
    }
    \%methods;
}

sub _autoload {
    my $self = shift;
    my $name = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    my ($encompasser, $controller) = __split_ns($1);
    if (my $code   = $COMPLEX{$encompasser}{$controller}{methods}{$name}) {
        return $code->($self, @_);
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $self || $self) . '"';
}

sub clean {
    my ($class, $obj) = @_;
}

1;

__END__
