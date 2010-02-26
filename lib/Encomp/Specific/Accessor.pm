package Encomp::Specific::Accessor;

use Encomp::Exporter;

# Class::Accessor::Fast is respected.

use Carp qw/croak/;
use Encomp::Util;

Encomp::Exporter->setup_suger_features(as_is => [qw/accessor accessors/]);

sub accessor {
    my $class = caller;
    _make_accessors($class, shift);
}

sub accessors {
    my $class = caller;
    _make_accessors($class, @_);
}

# stole from Class::Accessor::_mk_accessors & remaked
sub _make_accessors {
    my ($class, @fields) = @_;
    for my $field (@fields) {
        for my $reserved (qw/DESTROY AUTOLOAD/) {
            croak "Having a data accessor named $reserved in '$class' is unwise."
                if $field eq $reserved;
        }
        my $accessor = _make_rw_accessor($field);
        my $fullname = "${class}::$field";
        if (defined &{$fullname}) {
            croak "$fullname accessor has been defined.";
        }
        Encomp::Util::reinstall_subroutine($class, $field => $accessor);
    }
}

sub _make_rw_accessor {
    my $field = shift;
    return sub {
        return $_[0]->{$field}         if @_ == 1;
        return $_[0]->{$field} = $_[1] if @_ == 2;
        croak "The argument that can be set is up to one.";
    };
}

1;

__END__
