package Prospero::Request;

use strict;
use warnings;

use base qw( Prospero::Object );

sub headers_in {
    my ( $self ) = @_;
    return $self->unimplemented();
}

sub param {
    my ( $self, $key, $value ) = @_;
    return $self->unimplemented();
}

sub form_value_for_key {
    my ( $self, $key ) = @_;
    my $value = $self->param( $key );
    return $value;
}

sub form_values_for_key {
    my ( $self, $key ) = @_;
    my @values = $self->param( $key );
    return \@values;
}

sub form_keys {
    my ( $self ) = @_;
    return [ $self->param() ];
}

sub header_for_key {
    my ( $self, $key ) = @_;
    return $self->unimplemented();
}

sub cookie_value_for_key {
    my ( $self, $key ) = @_;
    return $self->unimplemented();
}

1;