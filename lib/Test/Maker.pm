package Test::Maker;

use strict;
use warnings;

use Safe::Isa;
use Test::Maker::Corpus;

use base 'Class::Accessor::Class';

__PACKAGE__->mk_class_accessors(qw/ corpus /);

our $VERSION = '0.01';

sub import {
    my ( $class, %options ) = @_;

    my $corpus = $options{corpus};

    unless ( $corpus->$_isa('Test::Maker::Corpus') ) {

        $corpus = Test::Maker::Corpus->new(
            ref $corpus ? $corpus : { name => $corpus, dir => 'corpus' } );
    }

    $class->corpus( $options{corpus} // 'corpus' );
}




1;

__END__

=encoding utf-8

=head1 NAME

Test::Maker - Helper to build test corpuses

=head1 SYNOPSIS

First define your subclass of Test::Maker

    package My::Test::Maker;

    use base 'Test::Maker';



    1;

Then


    use Test::Maker corpus => 'my-test-corpus'; # default 'corpus'

=head1 DESCRIPTION

Test::Maker is

=head1 AUTHOR

Michael Jemmeson E<lt>mjemmeson@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2014- Michael Jemmeson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
