use inc::Module::Install;

name 'Encomp';

perl_version_from 'lib/Encomp.pm';

all_from 'lib/Encomp.pm';

my %requires = (
    'Class::Inspector' => 0,
    'Data::Util'       => 0.50,
    'Hash::Merge'      => 0.11,
    'Scalar::Util'     => 1.21,
    'Tree::Simple'     => 1.18,
    'List::Compare'    => 0.37,
    'YAML::Any'        => 0.67,
);

while (my ($key, $val) = each %requires) {
    requires $key => $val;
}

build_requires 'Test::More';
auto_include;
WriteAll;
