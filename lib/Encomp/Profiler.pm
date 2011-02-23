package Encomp::Profiler;

use strict;
use warnings;
use Data::Util;
use Encomp::Util;

{
    package #
        # initialize dummy class
        _EncompProfiler; use Encomp; no Encomp
}

{
    package #
        _EncompProfilingResults;
    use Class::Accessor::Lite (
        new => 1,
        rw  => [qw/
            name
            nodes
            loaded
            methods
            own_methods
        /],
    );
}

sub build_info {
    my ($encomp, @components) = @_;
    die 'There is no element' unless @_;
    Encomp::Util::load_class($encomp);
    unless ($encomp->isa('Encomp::Class::Encompasser')) {
        unshift @components, "$encomp";
        $encomp = '_EncompProfiler';
    }
    my $obj = $encomp->build([ @components ]);
    my $res = _EncompProfilingResults->new(
        name     => ref($obj),
        loaded   => $obj->complex->{loaded},
        methods  => {
            map { $_ => {
                from => (Data::Util::get_code_info($obj->complex->{methods}->{$_}))[0],
                code => $obj->complex->{methods}->{$_},
            } } keys %{ $obj->complex->{methods} }
        },
        own_methods => do {
            my $stash = Data::Util::get_stash(ref $obj);
            +{ map { $_ => { code => \&{$stash->{$_}} } } keys %{ $stash } }
        },
        nodes   => do {
            my @nodes;
            $obj->node->invoke(sub { push @nodes, shift->get_path });
            \@nodes
        },
    );
}

1;

__END__

=head1 NAME

Encomp::Profiler

=head1 SYNOPSIS

=head1 DESCRIPTION

blah blah blah

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
