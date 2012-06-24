package Prospero::RequestFrame;

use strict;

use base qw( Prospero::Object );

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    $self->{_renderedComponents} = {};
    return $self;
}

sub add_rendered_component {
    my ( $self, $component ) = @_;

    my $class = ref( $component );
    my $node_id = $component->node_id();

    push (@{ $self->{_rendered_components}->{$class} ||= [] }, $node_id );
    return $self;
}

1;