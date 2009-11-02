use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo;

    use Encomp::Exporter;

    Encomp::Exporter->setup_suger_features(
        applicant_isa => __PACKAGE__ . '::Object',
        as_is         => [qw/foo suger/],
    );

    sub foo   {}
    sub suger { __PACKAGE__ }

    package Foo::Object;

    sub me { __PACKAGE__ }
}

{
    package Bar;

    push our @ISA, 'Foo';

    use Encomp::Exporter;

    Encomp::Exporter->setup_suger_features(
        applicant_isa => __PACKAGE__ . '::Object',
        as_is         => [qw/bar suger/],
    );

    sub bar   {}
    sub suger { __PACKAGE__ }

    package Bar::Object;

    sub me { __PACKAGE__ }
}

{
    package Baz;

    push our @ISA, 'Bar';

    use Encomp::Exporter;

    Encomp::Exporter->setup_suger_features(
        applicant_isa => __PACKAGE__ . '::Object',
        as_is         => [qw/baz suger/],
    );

    sub baz   {}
    sub suger { __PACKAGE__ }

    package Baz::Object;

    sub me { __PACKAGE__ }
}

package Test::Foo;

Foo->import; ::diag 'use Foo;';

::can_ok 'Test::Foo', 'foo';
::can_ok 'Test::Foo', 'suger';
::ok ! Test::Foo->can('bar'),   'Test::Foo->can\'t(\'bar\')' ;
::ok ! Test::Foo->can('baz'),   'Test::Foo->can\'t(\'baz\')' ;

::is +Test::Foo->suger, 'Foo', 'suger is \'Foo\'';

Foo->unimport; ::diag 'no Foo;';

::ok ! Test::Foo->can('foo'),   'Test::Foo->can\'t(\'foo\')';
::ok ! Test::Foo->can('suger'), 'Test::Foo->can\'t(\'suger\')';

::is +Test::Foo->me, 'Foo::Object';

::is_deeply \@Test::Foo::ISA, [qw/Foo::Object/];

package Test::Bar;

Bar->import; ::diag 'use Bar;';

::can_ok 'Test::Bar', 'foo';
::can_ok 'Test::Bar', 'bar';
::can_ok 'Test::Bar', 'suger';
::ok ! Test::Bar->can('baz'),   'Test::Bar->can\'t(\'baz\')' ;

::is +Test::Bar->suger, 'Bar', 'suger is \'Bar\'(The method of doing override becomes effective)';

Bar->unimport; ::diag 'no Bar;';

::ok ! Test::Bar->can('foo'),   'Test::Bar->can\'t(\'foo\')';
::ok ! Test::Bar->can('bar'),   'Test::Bar->can\'t(\'bar\')' ;
::ok ! Test::Bar->can('suger'), 'Test::Bar->can\'t(\'suger\')';

::is +Test::Bar->me, 'Bar::Object';

::is_deeply \@Test::Bar::ISA, [qw/Bar::Object Foo::Object/];

package Test::Baz;

Baz->import; ::diag 'use Baz;';

::can_ok 'Test::Baz', 'foo';
::can_ok 'Test::Baz', 'bar';
::can_ok 'Test::Baz', 'baz';
::can_ok 'Test::Baz', 'suger';

::is +Test::Baz->suger, 'Baz', 'suger is \'Baz\'(The method of doing override becomes effective)';

Baz->unimport; ::diag 'no Baz;';

::ok ! Test::Baz->can('foo'),   'Test::Baz->can\'t(\'foo\')';
::ok ! Test::Baz->can('bar'),   'Test::Baz->can\'t(\'bar\')' ;
::ok ! Test::Baz->can('baz'),   'Test::Baz->can\'t(\'baz\')' ;
::ok ! Test::Baz->can('suger'), 'Test::Baz->can\'t(\'suger\')';

::is +Test::Baz->me, 'Baz::Object';

::is_deeply \@Test::Baz::ISA, [qw/Baz::Object Bar::Object Foo::Object/];
