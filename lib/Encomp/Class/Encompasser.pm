package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::ProcessingNode;

Encomp::Class->setup_metadata(node => sub { Encomp::Meta::ProcessingNode->new });

sub build {
    Encomp::Complex->build(@_);
}

sub operate {
    my ($class, $controller, @args) = @_;
    my $obj   = build(@_);
    my $hooks = $obj->complex->{hooks};
    $class->node->invoke(sub {
        my ($self, $context) = @_;
        $obj->{context} = $context;
        if (my $codes = $hooks->{$self->{path_cached} || $self->get_path}) {
            for my $code (@{$codes}) {
                $code->($obj, @args);
            }
        }
        undef $obj->{context};
    });
    return $obj;
}

1;

__END__
