use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;
use lib "$FindBin::Bin/lib";

use DemoFW;

do {
    local *STDOUT;
    open STDOUT, '>:scalar', \(my $str);

    DemoFW->operate('DemoFW::Controller');

    is  $str, <<__STR__;
Content-Type: text/plain;

hello world
__STR__
};
