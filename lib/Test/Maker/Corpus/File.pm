package Test::Maker::Corpus::File;

use Moo;
use Types::Standard qw/ Str /;
use Types::Path::Tiny qw/ Path /;

use Config::INI::Reader;
use Config::INI::Writer;
use Path::Tiny qw/ path /;

has name => ( is => 'ro', required => 1, isa => Str );
has file =>
    ( is => 'ro', required => 1, isa => Path, coerce => Path->coercion );
has test_file => ( is => 'lazy' );
has config    => ( is => 'rw' );
has got       => ( is => 'rw' );
has expected  => ( is => 'lazy' ); # not really needed, just config->{expected}

sub _build_test_file { path( shift->file . '.test' ) }

sub _build_expected { shift->config->{expected} }

sub BUILD {
    my $self = shift;
    my $file = $self->file;
    die "$file doesn't exist or is not readable" unless -r $file;

    $self->config( Config::INI::Reader->read_file( $self->test_file ) )
        unless $self->config || !-e $self->test_file;
}

sub write_config {
    my $self = shift;

    Config::INI::Writer->write_file( $self->config, $self->test_file );

    return $self;
}

# subclass if required
sub read {
    my ( $self ) = @_;

    # TODO check mode etc
    return $self->file->slurp( { binmode => ":raw" } );
}

sub create {
    my ( $self, $create_expected ) = @_;

    if ( $self->test_file->exists ) {
        warn $self->test_file . " already exists";
        return;
    }

    my $data = $self->read();

    my $expected
        = $create_expected
        ? $create_expected->($data)
        : $self->create_expected($data);

    $self->config(
        {   '_'      => { name => $self->name },
            expected => $expected,
        }
    );

    $self->write_config();

}

# subclass
sub create_expected {
    die "create_expected not defined in subclass";
}

# subclass to do more
sub run {
    my ( $self, $run ) = @_;

    my $data = $self->read();

    my $got = $run ? $run->($data) : { test => $data };

    $self->got($got);
}

1;

