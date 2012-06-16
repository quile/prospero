package Prospero::Response;

use strict;
use warnings;

use base qw( Prospero::Object );

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    $self->set_content( "" );
    return $self;
}

sub append_content_string {
    my ( $self, $string ) = @_;
    $self->{_content} .= $string;
}

sub content     { return $_[0]->{_content} }
sub set_content { $_[0]->{_content} = $_[1] }

1;