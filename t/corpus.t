use Test::Most;

use strict;
use warnings;

use Directory::Scratch;

use Test::Maker::Corpus;

my $scratch_dir = Directory::Scratch->new();
my $dir         = $scratch_dir->mkdir('corpus');    # Path:Class obj

note "Constructor";

dies_ok { Test::Maker::Corpus->new() } "dies with no args";

ok my $corpus = Test::Maker::Corpus->new( name => 'mytest' ), "new";
is $corpus->dir, 'corpus/mytest', 'dir ok';

ok $corpus = Test::Maker::Corpus->new( name => 'mytest', dir => $dir ), "new";
is $corpus->dir, $scratch_dir . '/corpus', 'dir ok';

note "add";

ok $corpus->add('t/samples/basic-string'), "add";
ok -e $dir->file('0001-basic-string'), "file copied to test corpus";

ok $corpus->add('t/samples/basic-string2'), "add";
ok -e $dir->file('0002-basic-string2'), "file copied to test corpus";

note "list";

ok my @list = $corpus->list, "list";
is scalar(@list), 2, "got 2 tests";
is $list[0]->basename, '0001-basic-string',  "found basic-string";
is $list[1]->basename, '0002-basic-string2', "found basic-string2";

note "create_test";

dies_ok { $corpus->create_test('foo') } "dies with invalid test";
dies_ok { $corpus->create_test('0001-basic-string') }
"dies with no expected coderef";

my $run = sub { { match => $_[0] =~ m/foo/i ? 1 : 0 } };

ok $corpus->create_test( '0001-basic-string', $run ), "create test";
ok -e $dir->file('0001-basic-string.test'), ".test file created";

note "run_test";

$corpus->run( '0001-basic-string', $run ), "run_test";

done_testing();

