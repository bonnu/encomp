package DemoFW::Plugin::Response;

use Encomp::Plugin;

sub response {
    my $self = shift;
    $self->{response} ||= {};
}

sub output {
    my $self = shift;
    print $self->response->{body}, "\n";
}

no  Encomp::Plugin;

1;
