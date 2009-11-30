package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::Composite;
use Encomp::Meta::ProcessingNode;

Encomp::Class->setup_metadata(
    node => sub { Encomp::Meta::ProcessingNode->new },
);

sub operate {
    my ($class, $controller, @args) = @_;
    my $obj = Encomp::Complex->build($class => $controller);
    eval {
        $class->node->invoke(sub {
            my ($self, $context) = @_;
            if (my $hooks = $obj->complex->{hooks}{$self->get_path}) {
                for my $code (@{$hooks}) {
                    my $ret = $code->($obj, $context, @args);
                    return 0 unless $ret;
                }
            }
            return 1;
        });
    };
    my $err = $@;
    my $ret = Encomp::Complex->dischain($obj);
    if ($err) {
        die $err;
    }
    return $ret;
}

1;

__END__
