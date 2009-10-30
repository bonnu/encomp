package Encomp::Class::Controller;

use Encomp::Class;
use Encomp::Complex;

Encomp::Class->setup_metadata(
    hook    => sub { +{} },
    plugins => sub { +[] },
);

1;

__END__
