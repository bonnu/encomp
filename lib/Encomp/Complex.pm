package Encomp::Complex;

use Encomp::Util;
require Encomp::Base;
use Carp qw/croak/;
use Digest::MD5 qw/md5_hex/;
use UNIVERSAL::can;

sub build {
    my $class   = shift;
    my $package = _initialize(@_);
    bless {}, $package;
}

sub _initialize {
    my ($encompasser, $adhoc) = @_;
    my @adhoc   = ($adhoc && ref $adhoc) ? @{$adhoc} : $adhoc || ();
    my $id      = '_' . (0 < @adhoc ? md5_hex join '', sort @adhoc : '');
    my $package = join '::', $encompasser, '_complexed', $id;
    unless (Encomp::Util::get_code_ref($package, 'complex')) {
        my $complex = Encomp::Base->conflate($encompasser, @adhoc);
        Encomp::Util::reinstall_subroutine(
            $package,
            AUTOLOAD => \&_autoload,
            can      => \&_can,
            complex  => sub { $complex },
        );
    }
    return $package;
}

sub _autoload {
    my $proto = $_[0];
    my $name  = our $AUTOLOAD;
    $name =~ s/(^.*):://o;
    $name eq 'DESTROY' && return;
    my $package = $1;
    if (my $symbol = $proto->complex->{methods}{$name}) {
        Encomp::Util::reinstall_subroutine($package, $name => \&{$symbol});
        goto \&{$symbol};
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

sub _can {
    $_[0]->complex->{methods}{$_[1]} || do { no warnings; UNIVERSAL::can(@_) }
}

1;

__END__

=h1 NAME

Encomp::Complex

=h1 DESCRIPTION

The class group composed of mechanism of Encomp is synthesized.

=h1 SYNOPSIS

 my $creature = Encomp::Complex->build($design_class, $controller_class);

=h1

=cut
