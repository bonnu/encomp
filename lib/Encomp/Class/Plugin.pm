package Encomp::Class::Plugin;

use Encomp::Class;
use Encomp::Complex;
use Encomp::Meta::Composite;

Encomp::Class->setup_metadata(
    composite => sub { Encomp::Meta::Composite->new },
);

1;

__END__
