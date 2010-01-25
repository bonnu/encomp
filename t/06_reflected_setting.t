use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo;
    use Encomp;
    processes
        before =>
        main   =>
        after  =>
    ;
    no  Encomp;
}

{
    package Bar;
    use Encomp qw/+Accessor/;

    incorporate 'Foo';

    accessor 'message';

    hook_to '/main' => sub {
        my $self = shift;
        $self->message('hello');
    };

    no  Encomp;
}

{
    package Baz;
    use Encomp;

    incorporate 'Bar';

    hook_to '/main' => sub {
        my $self = shift;
        $self->message($self->message . ' world');
    };

    no  Encomp;
}

is 'hello',       Bar->operate->message;
is 'hello world', Baz->operate->message;
