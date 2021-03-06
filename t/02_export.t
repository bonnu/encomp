use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo;

    use Encomp::Exporter;

    setup_sugar_features
        applicant_isa => __PACKAGE__ . '::Object',
        as_is         => [qw/foo sugar/],
    ;

    sub foo   {}
    sub sugar { __PACKAGE__ }

    package Foo::Object;

    sub me { __PACKAGE__ }
}

{
    package Bar;

    push our @ISA, 'Foo';

    use Encomp::Exporter;

    setup_sugar_features
        applicant_isa => __PACKAGE__ . '::Object',
        as_is         => [qw/bar sugar/],
        specific_with => [qw/Qux/],
    ;

    sub bar   {}
    sub sugar { __PACKAGE__ }

    package Bar::Object;

    sub me { __PACKAGE__ }
}

{
    package Baz;

    push our @ISA, 'Bar';

    use Encomp::Exporter;

    setup_sugar_features
        applicant_isa => __PACKAGE__ . '::Object',
        as_is         => [qw/baz sugar/],
    ;

    sub baz   {}
    sub sugar { __PACKAGE__ }

    package Baz::Object;

    sub me { __PACKAGE__ }

    package Qux;

    use Encomp::Exporter;

    setup_sugar_features
        as_is => [qw/qux/],
    ;

    sub qux   {}
}

package Test::Foo;

Foo->import; #::diag 'use Foo;';

::can_ok 'Test::Foo', 'foo';
::can_ok 'Test::Foo', 'sugar';
::ok ! Test::Foo->can('bar'),   'Test::Foo->can\'t(\'bar\')' ;
::ok ! Test::Foo->can('baz'),   'Test::Foo->can\'t(\'baz\')' ;

::is +Test::Foo->sugar, 'Foo', 'sugar is \'Foo\'';

Foo->unimport; #::diag 'no Foo;';

::ok ! Test::Foo->can('foo'),   'Test::Foo->can\'t(\'foo\')';
::ok ! Test::Foo->can('sugar'), 'Test::Foo->can\'t(\'sugar\')';

::is +Test::Foo->me, 'Foo::Object';

::is_deeply \@Test::Foo::ISA, [qw/Foo::Object/];

package Test::Bar;

Bar->import; #::diag 'use Bar;';

::can_ok 'Test::Bar', 'foo';
::can_ok 'Test::Bar', 'bar';
::can_ok 'Test::Bar', 'qux';
::can_ok 'Test::Bar', 'sugar';
::ok ! Test::Bar->can('baz'),   'Test::Bar->can\'t(\'baz\')' ;

::is +Test::Bar->sugar, 'Bar', 'sugar is \'Bar\'(The method of doing override becomes effective)';

Bar->unimport; #::diag 'no Bar;';

::ok ! Test::Bar->can('foo'),   'Test::Bar->can\'t(\'foo\')';
::ok ! Test::Bar->can('bar'),   'Test::Bar->can\'t(\'bar\')' ;
::ok ! Test::Bar->can('qux'),   'Test::Bar->can\'t(\'qux\')' ;
::ok ! Test::Bar->can('sugar'), 'Test::Bar->can\'t(\'sugar\')';

::is +Test::Bar->me, 'Bar::Object';

::is_deeply \@Test::Bar::ISA, [qw/Bar::Object Foo::Object/];

package Test::Baz;

Baz->import; #::diag 'use Baz;';

::can_ok 'Test::Baz', 'foo';
::can_ok 'Test::Baz', 'bar';
::can_ok 'Test::Baz', 'qux';
::can_ok 'Test::Baz', 'baz';
::can_ok 'Test::Baz', 'sugar';

::is +Test::Baz->sugar, 'Baz', 'sugar is \'Baz\'(The method of doing override becomes effective)';

Baz->unimport; #::diag 'no Baz;';

::ok ! Test::Baz->can('foo'),   'Test::Baz->can\'t(\'foo\')';
::ok ! Test::Baz->can('bar'),   'Test::Baz->can\'t(\'bar\')' ;
::ok ! Test::Baz->can('qux'),   'Test::Baz->can\'t(\'qux\')' ;
::ok ! Test::Baz->can('baz'),   'Test::Baz->can\'t(\'baz\')' ;
::ok ! Test::Baz->can('sugar'), 'Test::Baz->can\'t(\'sugar\')';

::is +Test::Baz->me, 'Baz::Object';

::is_deeply \@Test::Baz::ISA, [qw/Baz::Object Bar::Object Foo::Object/];
