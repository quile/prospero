package Prospero::Utility;

use strict;
use warnings;

use Exporter qw( import );

our @EXPORT_OK = qw(
    array_from_object
);

sub array_from_object {
    my ( $object ) = @_;
    return [] unless defined $object;
    if ( ref( $object ) eq "ARRAY" ) {
        return $object;
    }
    return [ $object ];
}

1;