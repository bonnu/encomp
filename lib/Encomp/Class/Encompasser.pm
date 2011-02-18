package Encomp::Class::Encompasser;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::ProcessingNode;
use Scalar::Util ();

setup_metadata node => sub { Encomp::Meta::ProcessingNode->new };

sub build {
    Encomp::Complex::build(@_);
}

sub operate {
    my ($class, $controller, @args) = @_;
    my $obj       = build(@_);
    my $hooks     = $obj->complex->{hooks};
    my $modifiers = $obj->complex->{process_modifiers};
    my $callback  = sub {
        my ($node, $context) = @_;
        $obj->{context} = $context;
        $context->{stash} || $context->stash($obj);
        if (my $codes = $hooks->{$node->{path_cached} || $node->get_path}) {
            for my $code (@{$codes}) {
                $code->($obj, @args);
            }
        }
        undef $obj->{context};
    }; 
    $class->node->invoke($callback, $modifiers);
    return $obj;
}

1;

__END__
