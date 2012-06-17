package Prospero::Binding;

use strict;
use warnings;

use base qw( Prospero::Object );

sub name     { return $_[0]->{name}  }
sub set_name { $_[0]->{name} = $_[1] }

sub type {
    my ( $self ) = @_;
    return $self->{type} || $self->{component}; # allow either
}

1;