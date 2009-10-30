package Encomp::Controller;

use Encomp::Exporter;

Encomp::Exporter->setup_suger_features(
    applicant_isa => 'Encomp::Class::Controller',
    as_is         => [qw/hook_to/],
);

sub hook_to {
    my $class = caller;
    my ($hook, $callback) = @_;
    push @{ $class->hook->{$hook} ||= [] }, $callback;
}

sub plugins {
    my $class = caller;
    push @{$class->plugins}, ref $_[0] ? @{$_[0]} : @_;
}

1;

__END__

=head1 NAME

Encomp::Controller - Controller

=head1 SYNOPSIS

 package Foo::Controller;

 use Encomp::Controller;
 
 hook_to '/initialize' => sub {
     my $self = shift;
 };

 hook_to '/dispatch/main' => sub {
     my $self = shift;
 };

 package main;
 
 Foo::Encompasser->operate('Foo::Controller');

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
