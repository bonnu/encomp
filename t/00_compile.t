use strict;
use Test::More 'no_plan';

BEGIN {
    use_ok $_ for qw/
        Encomp
        Encomp::Controller
        Encomp::Class::Encompasser
        Encomp::Class::Controller
    /;
}
