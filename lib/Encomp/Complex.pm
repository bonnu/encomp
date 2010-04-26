package Encomp::Complex;

use Encomp::Util;
require Encomp::Base;
use Carp qw/croak/;
use Digest::MD5 qw/md5_hex/;
use UNIVERSAL::can;

sub build {
    my ($encompasser, $adhoc, @args) = @_;
    my $package = _initialize($encompasser => $adhoc);
    bless { arguments => \@args }, $package;
}

sub _initialize {
    my ($encompasser, $adhoc) = @_;
    my $ref     = ref $adhoc;
    my @adhoc   = ($adhoc && $ref && $ref eq 'ARRAY') ? @{$adhoc} : $adhoc || ();
    my $id      = '_' . (0 < @adhoc ? md5_hex join '/', sort @adhoc : '');
    my $package = join '::', $encompasser, '_complexed', $id;
    unless (Encomp::Util::get_code_ref($package, 'complex')) {
        my $complex = Encomp::Base->conflate($encompasser, @adhoc);
        Encomp::Util::reinstall_subroutine(
            $package,
            AUTOLOAD  => \&_autoload,
            arguments => \&_arguments,
            can       => \&_can,
            complex   => sub { $complex },
            context   => sub { $_[0]->{context} },
            loaded    => \&_loaded,
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
    if (my $method = $proto->complex->{methods}{$name}) {
        Encomp::Util::reinstall_subroutine($package, $name => $method);
        goto $method;
    }
    croak qq{Can't locate object method "$name" via package "} . (ref $proto || $proto) . '"';
}

sub _arguments {
    wantarray ? @{ $_[0]->{arguments} } : $_[0]->{arguments}
}

sub _can {
    $_[0]->complex->{methods}{$_[1]} || do { no warnings; UNIVERSAL::can(@_) }
}

sub _loaded {
    my ($self, $plugin_name) = @_;
    grep /$plugin_name/, @{$self->complex->{loaded}}
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
