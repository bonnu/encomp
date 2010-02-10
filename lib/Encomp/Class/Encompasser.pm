package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::ProcessingNode;
use Scalar::Util ();

Encomp::Class->setup_metadata(node => sub { Encomp::Meta::ProcessingNode->new });

sub build {
    my ($class, $controller) = @_;
    Encomp::Complex->build($class => $controller);
}

sub operate {
    my ($class, @args) = @_;
    my $obj   = Scalar::Util::blessed($class) ? $class : build($class, shift @args);
    my $hooks = $obj->complex->{hooks};
    $obj->node->invoke(sub {
        my ($self, $context) = @_;
        if (my $codes = $hooks->{$self->{path_cached} || $self->get_path}) {
            for my $code (@{$codes}) {
                $code->($obj, $context, @args);
            }
        }
    });
    return $obj;
}

1;

__END__
