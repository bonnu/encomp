package Encomp::Controller;

use Encomp::Exporter;
use base qw/Encomp::Base/;

setup_suger_features
    applicant_isa => 'Encomp::Class::Controller',
    specific_ns   => 'Encomp::Specific',
    specific_with => [qw/
        +Hook
        +Plugin
    /],
;

1;

__END__

=head1 NAME

Encomp::Controller - Controller

=head1 SYNOPSIS

 package Foo::Controller;

 use Encomp::Controller;
 
 hook_to '/initialize'    => sub { my $self = shift; ... };
 hook_to '/dispatch/main' => sub { my $self = shift; ... };

 package main;
 
 Foo::Encompasser->operate('Foo::Controller');

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
