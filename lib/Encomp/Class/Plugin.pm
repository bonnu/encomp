package Encomp::Class::Plugin;

use Encomp::Class;
use Encomp::Meta::Composite;

Encomp::Class->setup_metadata(composite => sub { Encomp::Meta::Composite->new(@_) });

1;

__END__
