package Test::Maker::Corpus;

use Moo;

use Path::Tiny qw/ path /;
use Types::Path::Tiny qw/ Path /;
use Test::Most;

has name => ( is => 'ro', required => 1 );
has dir => (
    is      => 'lazy',
    isa     => Path,
    coerce  => Path->coercion,
);
has corpus_file_class => ( is => 'lazy' );

sub _build_dir { path( 'corpus/' . shift->name ) }

sub _build_corpus_file_class {
    my $self = shift;

    my $corpus_file_class = ref($self) . '::File';
    eval "require $corpus_file_class";
    die "Can't load $corpus_file_class: $@" if $@;
    return $corpus_file_class;
}

sub list {
    my $self = shift;
    return    #
        sort { $a->basename cmp $b->basename }
        grep { $_->basename !~ m/\.test$/ }      #
        $self->dir->children(qr/^\d{4}-/);
}

# add file to test corpus
sub add {
    my ( $self, $file ) = @_;

    my $src = path($file);

    my $index = 1;

    if ( my @list = $self->list ) {
        my ($max) = $list[-1]->basename =~ m/^(\d{4})/;
        $index = $max + 1;
    }

    $src->copy( sprintf( "%s/%04d-%s", $self->dir, $index, $src->basename ) );

    return $self;
}

# creates the .test file
sub create_test {
    my ( $self, $name, $create_expected ) = @_;

    my $file = $self->corpus_file_class->new(
        name => $name,
        file => $self->dir . "/$name",
    );

    $file->create( $create_expected );

    return $self;
}

sub run {
    my ( $self, $name, $run ) = @_;

    my $file = $self->corpus_file_class->new(
        name => $name,
        file => $self->dir . "/$name",
    );

    $file->run($run);

    # FIXME ensure have {} in ->got
    # TODO check for die etc

    foreach my $field (sort keys %{$file->expected}) {
        if (ref $field) {
            is_deeply $file->expected->{$field}, $file->got->{$field}, "$field ok";
        } else {
            is $file->expected->{$field}, $file->got->{$field}, "$field ok";
        }
    }
}

# delete file from test corpus
sub delete {

}






1;

__END__

# object to represent Test Corpus (directory of test data)



