package DemoFW::Controller;

use Encomp::Controller;

sub dispatch {
    my $self = shift;
    $self->response->{body} = 'hello world';
}

no  Encomp::Controller;

1;
