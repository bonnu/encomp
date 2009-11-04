package Encomp;

use Encomp::Exporter;

our $VERSION = '0.01';

Encomp::Exporter->setup_suger_features(
    applicant_isa => 'Encomp::Class::Encompasser',
    as_is         => [qw/processes hook_to plugins/],
);

sub processes {
    my $class = caller;
    $class->node->append_nodes({ level => 1 }, @_);
}

sub hook_to {
    my $class = caller;
    $class->composite->add_hook(@_);
}

sub plugins {
    my $class = caller;
    $class->composite->add_plugins(ref $_[0] ? @{$_[0]} : @_);
}

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

Composite Class (Controller + Role) in Encompassing Class

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
