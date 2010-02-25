package Encomp::Specific::ClassAccessor;

use Encomp::Exporter;

# Class::Data::Accessor is respected.

use Carp qw/carp croak/;
use Sub::Name ();

Encomp::Exporter->setup_suger_features(as_is => [qw/class_accessor/]);

sub class_accessor {
    my $class = caller;
    _make_class_accessor($class, @_);
}

# stole from Class::Data::Accessor::mk_classaccessor & remaked
sub _make_class_accessor {
    my ($class, $field, $data) = @_;
    if (ref $class) {
        croak "_make_class_accessor() is like a class method, not an object method.";
    }
    for my $reserved (qw/DESTROY AUTOLOAD/) {
        croak "Having a data accessor named $reserved in '$class' is unwise."
            if $field eq $reserved;
    }
    my $accessor = _make_class_data_accessor($class, $field, $data);
    my $fullname = "${class}::$field";
    if (defined &{$fullname}) {
        carp "$fullname accessor has been defined."
            unless do { no strict 'refs'; defined &{"${class}::complex"} };
    }
    Encomp::Util::reinstall_subroutine($class, $field => $accessor);
    $accessor;
}

sub _make_class_data_accessor {
    my ($class, $field, $data) = @_;
    return sub {
        if (ref $_[0]) {
          return $_[0]->{$field} = $_[1] if @_ > 1;
          return $_[0]->{$field}         if exists $_[0]->{$field};
        }
        my $wantclass = ref($_[0]) || $_[0];
        return _make_class_accessor($wantclass, $field)->(@_)
            if @_ > 1 && $wantclass ne $class;
        $data = $_[1] if @_ > 1;
        return $data;
    };
}

1;

__END__
