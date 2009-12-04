package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::ProcessingNode;

Encomp::Class->setup_metadata(node => sub { Encomp::Meta::ProcessingNode->new });

sub operate {
    my ($class, $controller, @args) = @_;
    my $obj   = Encomp::Complex->build($class => $controller);
    my $hooks = $obj->complex->{hooks};
    eval {
        $class->node->invoke(sub {
            my ($self, $context) = @_;
            if (my $codes = $hooks->{$self->{_path_compiled} || $self->get_path}) {
                for my $code (@{$codes}) {
                    $code->($obj, $context, @args);
                }
            }
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
