use Test::More;

use strict;
use warnings;

my $pkg = 'Test::Maker';

use_ok( $pkg, corpus => 'mytest' );

is $pkg->corpus, 'mytest', 'corpus name set ok';

done_testing;

