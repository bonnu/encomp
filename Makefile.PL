use inc::Module::Install;
name 'Encomp';
all_from 'lib/Encomp.pm';

build_requires 'Test::More';
auto_include;
WriteAll;
