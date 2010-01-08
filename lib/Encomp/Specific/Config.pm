package Encomp::Specific::Config;

use Encomp::Exporter;
use base qw/Encomp::Specific::Plugin/;
use Carp qw/croak/;
use YAML::Any ();
use Hash::Merge;

Encomp::Exporter->setup_suger_features(as_is => [qw/config/]);

sub config {
    my $class = caller;
    my $stash = $class->composite->stash->{config} ||= {};
    my $conf  = 1 == @_ ? shift : +{ @_ };
    if (my $ref = ref $conf) {
        $ref eq 'HASH' or
            croak 'The parameter should be a reference of HASH or a filename of yaml.';
    }
    else {
        $conf = YAML::Any::LoadFile($conf);
    }
    %{$stash} = %{Hash::Merge::merge($conf, $stash)};
}

1;

__END__
