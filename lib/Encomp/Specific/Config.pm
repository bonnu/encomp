package Encomp::Specific::Config;

use Encomp::Exporter;
use parent qw/Encomp::Specific::Plugin/;
use Carp qw/croak/;
use File::Spec;
use Hash::Merge;
use YAML::Any ();

setup_suger_features as_is => [qw/config/];

suger_feature config => sub {
    my $class  = shift;
    my $stash  = $class->composite->stash->{config} ||= {};
    my $config = 1 == @_ ? shift : +{ @_ };
    if (my $ref = ref $config) {
        $ref eq 'HASH' or
            croak 'The parameter should be a reference of HASH or a filename of yaml.';
    }
    else {
        (my $inc = "$class.pm") =~ s!::!/!o;
        my $path;
        if ($path = $INC{$inc}) {
            $path =~ s/\Q$inc\E//;
        }
        else {
            my @paths = File::Spec->splitdir((caller 0)[1]);
            $path = File::Spec->catdir(splice @paths, 0, $#paths);
        }
        $config = File::Spec->rel2abs($config, $path);
        $config = YAML::Any::LoadFile($config);
    }
    %{$stash} = %{Hash::Merge::merge($config, $stash)};
};

1;

__END__
