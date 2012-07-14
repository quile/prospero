package Prospero::Object;

use strict;
use warnings;

use Carp qw( croak );
use Object::KeyValueCoding naming_convention => "underscore";

sub new {
    my ( $class, @args ) = @_;
    my $arguments = {};
    my $self = bless {}, $class;
    if ( scalar @args ) {
        if ( scalar @args == 1 && ref( $args[0] ) eq 'HASH' ) {
            $arguments = $args[0];
        } else {
            $arguments = { @args };
        }
    }
    foreach my $key ( keys %$arguments ) {
        $self->set_value_for_key( $arguments->{$key}, $key );
    }
    return $self;
}

sub init {
    my ( $self ) = @_;
    return $self;
}

sub unimplemented {
    my ( $self ) = @_;
    croak "Unimplemented";
}

sub self {
    return $_[0];
}

1;