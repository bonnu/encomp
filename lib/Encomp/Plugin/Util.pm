package Encomp::Plugin::Util;

use Encomp::Exporter;

Encomp::Exporter->setup_suger_features(
    metadata => {
        plugin_util => sub { Encomp::Meta::Composite::PluginUtil->new(@_) },
    },
    as_is    => [qw/property accessor/],
);

sub property {
    my $class = caller;
    $class->plugin_util->add_property(@_);
}

sub accessor {
    my $class = caller;
    $class->plugin_util->add_accessor(@_);
}

{
    package #
        Encomp::Meta::Composite::PluginUtil;

    use strict;
    use warnings;
    use base qw/Encomp::Meta::Composite/;

    sub properties { $_[0]->{properties} ||= [] }
    sub accessors  { $_[0]->{accessors}  ||= [] }

    sub add_property {
        my $self = shift;
        push @{ $self->properties }, @_;
    }
}

1;

__END__

=head1 NAME

Encomp::Plugin - Plugin

=head1 SYNOPSIS

 package Foo::Plugin;

 use Encomp::Plugin;
 
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
