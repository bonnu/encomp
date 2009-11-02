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
    my $obj = Encomp::Complex->build($class => $controller);
    eval {
        $class->node->invoke(sub {
            my ($self, $context) = @_;
            if (my $hooks = $controller->composite->hook->{$self->get_path}) {
                for my $code (@{$hooks}) {
                    my $ret = $code->($obj, $context, @args);
                    return 0 unless $ret;
                }
            }
            return 1;
        });
    };
    Encomp::Complex->clean($obj);
}

1;

__END__
