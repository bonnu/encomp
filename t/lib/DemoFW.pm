package DemoFW;

use Encomp;

processes qw/
    initialize
    main
    finalize
/;

plugins 'DemoFW::Plugin::Response';

hook_to '/initialize'
=> sub {
    my ($self, $context, @args) = @_;
    return 1;
};

hook_to '/main'
=> sub {
    my ($self, $context, @args) = @_;
    $self->dispatch;
    return 1;
};

hook_to '/finalize'
=> sub {
    my ($self, $context, @args) = @_;
    $self->output;
    return 1;
};

no  Encomp;

1;
