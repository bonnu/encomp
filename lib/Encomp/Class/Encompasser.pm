package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::Composite;
use Encomp::Meta::ProcessingNode;

Encomp::Class->setup_metadata(
    composite => sub { Encomp::Meta::Composite->new },
    node      => sub { Encomp::Meta::ProcessingNode->new },
);

sub operate {
    my ($class, $controller, @args) = @_;
    my $object = Encomp::Complex->build($class => $controller);
    my $hooks  = Encomp::Complex->load_hooks($object);
    eval {
        $class->node->invoke(sub {
            my ($self, $context) = @_;
            if (my $hooks = $hooks->{$self->get_path}) {
                for my $code (@{$hooks}) {
                    my $ret = $code->($object, $context, @args);
                    return 0 unless $ret;
                }
            }
            return 1;
        });
    };
    Encomp::Complex->clean($object);
}

1;

__END__
