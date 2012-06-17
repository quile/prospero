package Prospero::BindingDictionary;

use strict;
use warnings;

use base qw( Prospero::DictionaryStack );

use Prospero::Binding;

sub value_for_key {
    my ( $self, $key ) = @_;
    my $value = $self->SUPER::value_for_key( $key );
    return undef unless $value;
    if ( ref($value) eq "HASH" ) {
        return bless $value, "Prospero::Binding";
    }
    return $value;
}

1;