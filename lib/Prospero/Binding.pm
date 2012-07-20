package Prospero::Binding;

use strict;
use warnings;

use base qw( Prospero::Object );

sub binding_name     { return $_[0]->{_binding_name}  }
sub set_binding_name { $_[0]->{_binding_name} = $_[1] }

sub type {
    my ( $self ) = @_;
    return $self->{type} || $self->{component}; # allow either
}

1;