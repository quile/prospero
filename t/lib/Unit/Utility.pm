package Unit::Utility;

use strict;

use base qw( Test::Class );
use Test::More;

use Prospero::DictionaryStack;

use Prospero::Utility qw( array_from_object );

sub test_array : Tests {
    my ( $self ) = @_;

    my $scalar = "foo";
    my $array_ref = [ "foo", "bar" ];

    is_deeply( array_from_object( $scalar ), [ "foo" ], "Made array ref from scalar" );
    is_deeply( array_from_object( $array_ref ), [ "foo", "bar" ], "Made array ref from array ref" );
}

1;