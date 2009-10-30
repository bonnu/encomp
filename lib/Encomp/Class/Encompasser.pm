package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::ProcessingNode;

Encomp::Class->setup_metadata(
    root    => sub { Encomp::Meta::ProcessingNode->new },
    hook    => sub { +{} },
    plugins => sub { +[] },
);

sub operate {
    my ($class, $controller, @args) = @_;
    my $obj = Encomp::Complex->build($class => $controller);
    $class->root->invoke(sub {
        my ($self, $context) = @_;
        if (my $hooks = $controller->hook->{$self->get_path}) {
            for my $code (@{$hooks}) {
                my $ret = $code->($obj, $context, @args);
                return 0 unless $ret;
            }
        }
        return 1;
    });
    Encomp::Complex->clean($obj);
}

1;

__END__
