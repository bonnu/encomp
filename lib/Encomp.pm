package Encomp;

use Encomp::Exporter;
use parent qw/Encomp::Base/;
use Carp qw/croak/;

our $VERSION = '0.01';

my $applicant = 'Encomp::Class::Encompasser';

setup_suger_features
    applicant_isa => $applicant,
    as_is         => [qw/processes incorporate/],
    specific_ns   => 'Encomp::Specific',
    specific_with => [qw/
        +Config
        +DuckType
        +Hook
        +Plugin
    /],
;

suger_feature processes => sub {
    my $class = shift;
    $class->node->append_nodes(@_);
};

suger_feature incorporate => sub {
    my $class  = shift;
    my $plugin = shift;
    Encomp::Util::load_class($plugin);
    croak "Target plugin isn't isa('$applicant')" unless $plugin->isa($applicant);
    $class->node->append_nodes($plugin->node->get_all_ids);
    $class->composite->add_plugins($plugin);
};

1;

__END__

=head1 NAME

Encomp - Composite & Encompass Model

=head1 SYNOPSIS

 package Foo::Encompasser;

 use Encomp;

 # The flow of event with hook is defined
 processes
     'initialize',
     'dispatch' => [
         'before',
         'main',
         'after',
     ],
     'finalize',
 ;

 package main;
 
 Foo::Encompasser->operate('Foo::Controller');

=head1 DESCRIPTION

Composite Class (Controller + Plugins) in Encompassing Class

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
