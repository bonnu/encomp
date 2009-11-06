#!/usr/bin/env perl

use strict;
use warnings;

BEGIN {
    package FW;

    use Encomp::DSL;
    use Carp qw/croak/;

    process {
        local $SIG{__DIE__} = sub { croak $@ };
        eval {
            hook 'initialize';
            hook 'main' => process {
                hook 'before';
                hook 'dispatch';
                hook 'after';
            };
        };
        my $e = $@;
        hook 'catch' => condition { $e };
        hook 'finalize';
    };

    no  Encomp;
}

use Data::Dumper;
print Dumper(FW->node);
