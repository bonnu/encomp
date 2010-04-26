package Encomp::Specific::Accessor;

use Encomp::Exporter;

# Class::Accessor::Fast is respected.

use Carp qw/croak/;
use Encomp::Util;
use Storable qw/dclone/;

setup_suger_features as_is => [qw/accessor/];

sub accessor {
    my $class = caller;
    _make_accessor($class, @_);
}

# stole from Class::Accessor::_mk_accessors & remaked
sub _make_accessor {
    my ($class, $field, $default) = @_;
    for my $reserved (qw/DESTROY AUTOLOAD/) {
        croak "Having a data accessor named $reserved in '$class' is unwise."
            if $field eq $reserved;
    }
    my ($accessor, $code) = _make_rw_accessor($field, $default);
    my $fullname = "${class}::$field";
    if (defined &{$fullname}) {
        croak "$fullname accessor has been defined.";
    }
    my @init;
    if (defined $code) {
        my $initializer = _make_initializer($field, $code);
        push @init, "initial_$field" => $initializer;
    }
    Encomp::Util::reinstall_subroutine($class, $field => $accessor, @init);
}

sub _make_rw_accessor {
    my ($field, $default) = @_;
    my $code;
    if (defined $default) {
        my $ref = ref $default;
        $code  = $ref
            ? ($ref eq 'CODE' ? $default : sub { dclone $default })
            : sub { $default };
    }
    return sub {
        if (@_ == 1) {
            $_[0]->{$field} = $code->($_[0])
                if ! exists $_[0]->{$field} && defined $code;
            return $_[0]->{$field};
        }
        return $_[0]->{$field} = $_[1] if @_ == 2;
        croak "The argument that can be set is up to one.";
    }, $code;
}

sub _make_initializer {
    my ($field, $code) = @_;
    sub { $_[0]->{$field} = $code->($_[0]) };
}

1;

__END__
