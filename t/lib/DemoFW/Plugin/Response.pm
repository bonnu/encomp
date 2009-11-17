package DemoFW::Plugin::Response;

use Encomp::Plugin;

sub response {
    my $self = shift;
    $self->{response} ||= {};
}

sub headers {
    my $self = shift;
    $self->response->{headers} ||= [];
}

sub headers_out {
    my $self = shift;
    my $out  = '';
    my $headers = $self->headers;
    push @{$headers}, [ 'Content-Type:', 'text/plain;' ] unless @{$headers};
    $out .= join(' ', @{$_}) . "\n" for @{$headers};
    return $out;
}

sub output {
    my $self = shift;
    return $self->response->{body} . "\n";
}

no  Encomp::Plugin;

1;
