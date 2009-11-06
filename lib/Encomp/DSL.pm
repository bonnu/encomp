package Encomp::DSL;

use Encomp::Exporter;
use Encomp::Meta::ProcessingNode;
use Carp qw/croak/;

our $VERSION = '0.01';

Encomp::Exporter->setup_suger_features(
    applicant_isa => 'Encomp::Class::Encompasser',
    as_is         => [qw/process hook condition/],
    metadata      => {
        settings => sub { +{} },
    },
);

my %processes;

our $_current;

sub process (&) {
    my $class = caller;
    my $code  = shift;
    if ($_current) {
        my $node = Encomp::Meta::ProcessingNode->new;
        local $_current = sub { $node };
        $code->();
        return $node;
    }
    else {
        my $node = $class->node;
        local $_current = sub { $node };
        $code->();
    }
}

sub hook ($;@) {
    my $class = caller;
    my $name  = shift;
    croak 'hook should be called inside process {} block'
        unless $_current;
    if (ref $_[0] eq 'Encomp::Meta::ProcessingNode') {
        my $node = shift;
        $node->setUID($name);
        $_current->()->addChild($node);
    }
    else {
        $_current->()->append_nodes($name);
    }
}

sub condition (&) {
    my $class = caller;
    my $code  = shift;
}

1;

__END__
