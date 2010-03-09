package DemoFW;

use Encomp;

processes qw/
    initialize
    main
    finalize
/;

plugins 'DemoFW::Plugin::Response';

hook_to '/initialize' =>
sub {
    my ($self, @args) = @_;
};

hook_to '/main' =>
sub {
    my ($self, @args) = @_;
    $self->dispatch;
};

hook_to '/finalize' =>
sub {
    my ($self, @args) = @_;
    print $self->headers_out;
    print "\n";
    print $self->output;
};

no  Encomp;

1;
