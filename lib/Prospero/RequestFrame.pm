package Prospero::RequestFrame;

use strict;

use base qw( Prospero::Object );

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    $self->{_rendered_components} = {};
    return $self;
}

sub add_rendered_component {
    my ( $self, $component ) = @_;

    my $class = ref( $component );
    my $node_id = $component->node_id();

    $self->{_rendered_components}->{$class} ||= {};
    $self->{_rendered_components}->{$class}->{$node_id}++;
    return $self;
}

sub did_render_component {
    my ( $self, $component ) = @_;

    my $class = ref( $component );
    my $node_id = $component->node_id();

    return exists $self->{_rendered_components}->{$class}
        && exists $self->{_rendered_components}->{$class}->{$node_id};
}

sub rendered_components {
    my ( $self ) = @_;
    return $self->{_rendered_components};
}

1;