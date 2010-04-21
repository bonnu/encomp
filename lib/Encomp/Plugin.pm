package Encomp::Plugin;

use Encomp::Exporter;
use base qw/Encomp::Base/;

Encomp::Exporter->setup_suger_features(
    applicant_isa => 'Encomp::Class::Plugin',
    specific_ns   => 'Encomp::Specific',
    specific_with => [qw/
        +DuckType
        +Hook
        +Plugin
    /],
);

1;

__END__

=head1 NAME

Encomp::Plugin - Plugin

=head1 SYNOPSIS

 package Foo::Plugin;

 use Encomp::Plugin;
 
 hook_to '/initialize'    => sub { my $self = shift; ... };
 hook_to '/dispatch/main' => sub { my $self = shift; $self->foo };

 package Foo::Controller;

 use Encomp::Controller;

 plugins qw/Foo::Plugin/;

 sub foo { warn 'foo' }
 
 package main;
 
 Foo::Encompasser->operate('Foo::Controller');

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
