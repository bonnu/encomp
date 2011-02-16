package Encomp::Profiler;

use strict;
use warnings;
use Data::Util;

{
    package
        _EncompProfiler;
    use Encomp;
    no  Encomp;
}

{
    package
        _EncompProfilingResults;
    use Class::Accessor::Lite (
        new => 1,
        rw  => [qw/
            name
            instance
            loaded
            methods
            own_methods
        /],
    );
}

sub build_info {
    my @classes = @_;
    my $obj = _EncompProfiler->build([ @classes ]);
    my $res = _EncompProfilingResults->new(
        name     => ref($obj),
#       instance => $obj,
        loaded   => $obj->complex->{loaded},
        methods  => {
            map { $_ => {
                from => (Data::Util::get_code_info($obj->complex->{methods}->{$_}))[0],
                code => $obj->complex->{methods}->{$_},
            } } keys %{ $obj->complex->{methods} }
        },
        own_methods => {
            do {
                my $stash = Data::Util::get_stash(ref $obj);
                map { $_ => { code => \&{$stash->{$_}} } } keys %{ $stash }
            },
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
