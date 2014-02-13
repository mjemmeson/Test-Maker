use Test::Most;

use Test::Maker::Corpus::File;

ok my $file = Test::Maker::Corpus::File->new(
    name => '0123-sample-test',
    file => 't/samples/0123-sample-test'
    ),
    "new";

is_deeply $file->config,
    {
    '_'      => { name => '0123-sample-test' },
    expected => { test => 'Sample test' },
    },
    "config ok";

ok $file->config(
    {   '_'      => { name => '0123-sample-test' },
        expected => { test => 'Sample test - foo' },
    }
    ),
    "updated config";

ok $file->run(), "run";

done_testing();
