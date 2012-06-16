package Prospero::Component;

use strict;
use warnings;

use base qw( Prospero::Object );


sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    unless ( $context->render_state() ) {
        $context->set_render_state( Prospero::RenderState->new() );
    }


}

sub append_to_response {
    my ( $self, $response, $context ) = @_;

    unless ( $context->render_state() ) {
        $context->set_render_state( Prospero::RenderState->new() );
    }

    my $rendered_content = $self->render_in_context( $context, $render_state );
    my $resolved_content = $self->resolve_rendered_content( $rendered_content, $context, $render_state );

    $response->append_content_string( $resolved_content );
}

sub render_in_context {
    my ( $self, $context ) = @_;

    $self->unimplemented();
}

sub resolve_rendered_content {
    my ( $self, $rendered_content, $context, $render_state ) = @_;
}

1;