package Prospero::Component;

use strict;
use warnings;

use Try::Tiny;

use Prospero::BindingDictionary;

use base qw( Prospero::Object );

sub CONTENT_TAG { "<__CONTENT__>" }

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    $self->{_subcomponents} = {};
    return $self;
}

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
    # return content
    # $response->appendContentString( $content );
}

sub render_in_context {
    my ( $self, $context ) = @_;

    my $response = Prospero::Response->new();
    $self->append_to_response( $response, $context );
    return $response->content();
}

sub resolve_rendered_content {
    my ( $self, $rendered_content, $context, $render_state ) = @_;
}

# Override this in all your components
sub bindings {
    my ( $self ) = @_;
    return Prospero::BindingDictionary->new();
}

sub binding_with_name {
    my ( $self, $name ) = @_;
    my $binding = $self->bindings()->value_for_key( $name );
    return undef unless $binding;
    $binding->set_name( $name );
    return $binding;
}

sub component_for_binding {
    my ( $self, $binding ) = @_;

    return undef unless $binding;
    my $cached_instance = $self->{_subcomponents}->{ $binding->name() };
    return $cached_instance if $cached_instance;
    my $component_class = $binding->type();

    try {
        $cached_instance = $component_class->new();
        $self->{_subcomponents}->{ $binding->name() } = $cached_instance;
        $self->context()->render_state()->increment_page_context_number();
        $cached_instance->set_page_context_number( $self->context()->render_state()->page_context_number() );
    } catch {
        warn sprintf( "Component class $component_class (referenced from binding '%s') does not exist", $binding->name() );
    };
    return $cached_instance;
}

sub context     { return $_[0]->{_context}  }
sub set_context { $_[0]->{_context} = $_[1] }
sub page_context_number     { return $_[0]->{_page_context_number}  }
sub set_page_context_number { $_[0]->{_page_context_number} = $_[1] }

1;