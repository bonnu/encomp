package DemoFW::Controller::Foo;

use DemoFW::Controller;

sub dispatch {
    my $self = shift;
    $self->response->{body} = 'hello world';
}

no  DemoFW::Controller;

1;
