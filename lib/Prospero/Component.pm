package Prospero::Component;

use strict;
use warnings;

use Try::Tiny;
use Carp qw( croak );
use Scalar::Util qw( weaken );
use Data::Dumper;

use Prospero::RenderState;
use Prospero::BindingDictionary;
use Prospero::Response;
use Prospero::Plugin;

use base qw( Prospero::Object );

sub CONTENT_TAG { "<__CONTENT__>" }
my $COMBINED_PAGE_RESOURCE_TAG = "<%_PAGE_RESOURCES_%>";
my $CSS_PAGE_RESOURCE_TAG = "<%_CSS_PAGE_RESOURCES_%>";
my $JS_PAGE_RESOURCE_TAG = "<%_JS_PAGE_RESOURCES_%>";

sub new {
    my ( $class, $render_state, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    unless ( $render_state ) {
        $render_state = Prospero::RenderState->new();
    }
    $self->set_render_state( $render_state );
    $self->{_node_id} = $render_state->next_node_id();
    $self->init();

    return $self;
}

sub init {}

sub will_respond {
    my ( $self, $request, $context ) = @_;

    $self->render_state()->increase_page_context_depth();
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->unimplemented();
}

sub did_respond {
    my ( $self, $request, $context ) = @_;

    $self->render_state()->decrease_page_context_depth();
}

sub will_render {
    my ( $self, $response, $context ) = @_;
    $self->render_state()->increase_page_context_depth();
    Prospero::Plugin->execute_callback_with_arguments( "will_render", $self, $response, $context );
}

sub append_to_response {
    my ( $self, $response, $context ) = @_;

    $self->unimplemented();
}

sub did_render {
    my ( $self, $response, $context ) = @_;
    $context->outgoing_request_frame()->add_rendered_component( $self );

    $self->render_state()->add_page_resources( $self->required_page_resources() );

    if ( $self->is_root_component() ) {
        $self->add_page_resources_to_response_in_context( $response, $context );
    }

    Prospero::Plugin->execute_callback_with_arguments( "did_render", $self, $response, $context );
    $self->render_state()->decrease_page_context_depth();
    $self->set_context();
}

sub render_in_context {
    my ( $self, $context ) = @_;

    my $response = Prospero::Response->new();

    $self->will_render( $response, $context );
    $self->append_to_response( $response, $context );
    $self->did_render( $response, $context );

    return $response->content();
}

sub rewind_request_in_context {
    my ( $self, $request, $context ) = @_;

    $self->will_respond( $request, $context );
    if ( $context->incoming_request_frame() ) {
        $self->take_values_from_request( $request, $context );
    }
    $self->did_respond( $request, $context );
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
    $binding->set_binding_name( $name );
    return $binding;
}

sub component_for_binding {
    my ( $self, $binding ) = @_;

    croak "Can't create component without context" unless $self->context();
    return undef unless $binding;

    my $component_class = $binding->type();
    my $component;
    try {
        $component = $component_class->new( $self->render_state() );
        $component->set_parent_binding_name( $binding->binding_name() );
        $component->set_context( $self->context() );
    } catch {
        warn sprintf( "Component class $component_class (referenced from binding '%s') does not exist", $binding->binding_name() );
    };
    return $component;
}

sub push_values_to_component {
    my ( $self, $component, $binding ) = @_;

    # set the bindings
    foreach my $key ( keys %$binding ) {
        next if ( $key eq "type" || $key eq "parent_binding_name" );
        my $bv = $binding->value_for_key( $key );
        my $value;
        if (ref( $bv ) eq "CODE" ) {
            $value = $bv->( $self );
        } else {
            $value = $self->value_for_key( $bv );
        }
        $component->set_value_for_key( $value, $key );
    }
}

sub pull_values_from_component {
    my ( $self, $component, $binding ) = @_;

    foreach my $key ( keys %$binding ) {
        next if ( $key eq "type" || $key eq "parent_binding_name" );
        my $bv = $binding->value_for_key( $key );
        unless ( ref( $bv ) ) {
            my $value = $component->value_for_key( $key );
            $self->set_value_for_key( $value, $bv );
        }
    }
}

sub page_with_name {
    my ( $self, $name, $context ) = @_;

    $context ||= $self->context();

    my $component_class = $self->component_class_for_name( $name, $context );
    croak( "Couldn't determine component class for $name" ) unless $component_class;

    my $page = $component_class->new( $context->render_state() );
    return $page;
}

# TODO:kd - make this a lot smarter.
sub component_class_for_name {
    my ( $self, $name, $context ) = @_;
    return $name;
}

sub is_root_component {
    my ( $self ) = @_;
    return $self->node_id eq "1";
}

# override this to declare external files (CSS, JS) that this
# component needs in order to function on the client
sub required_page_resources {
    return [];
}

sub add_page_resources_to_response_in_context {
    my ($self, $response, $context) = @_;

    my $content = $self->_content_with_page_resources_from_response( $response );
    $response->set_content( $content );
}

sub _content_with_page_resources_from_response {
    my ( $self, $response ) = @_;

    my $content = $response->content();
    my $css_resources = $self->page_resources_of_type_in_response_as_html( 'stylesheet' );
    my $js_resources = $self->page_resources_of_type_in_response_as_html( 'javascript' );
    # replace the tag even if it's with nothing ...
    my $all_resources = $css_resources.$js_resources;
    $content =~ s/$CSS_PAGE_RESOURCE_TAG/$css_resources/;
    $content =~ s/$JS_PAGE_RESOURCE_TAG/$js_resources/;
    $content =~ s/$COMBINED_PAGE_RESOURCE_TAG/$all_resources/;
    return $content;
}

sub page_resources_of_type_in_response_as_html {
    my ( $self, $type, $response ) = @_;

    my $resources = $self->render_state()->page_resources();
    return unless scalar @$resources;

    my $filtered_set = [];
    foreach my $r (@$resources) {
        push @$filtered_set, $r if $r->type() eq $type;
    }
    return unless @$filtered_set;

    my $content = "";
    foreach my $r (@$filtered_set) {
        $content .= $r->tag()."\n";
    }
    return $content;
}

sub tag_attribute_for_key {
    my ( $self, $name ) = @_;
    return $self->tag_attributes()->{$name};
}

sub tag_attribute_string {
    my ( $self ) = @_;
    my $kvpairs = [];
    foreach my $key ( keys %{ $self->tag_attributes() || {} } ) {
        my $value = $self->tag_attribute_for_key( $key );
        push @$kvpairs, qq($key="$value");
    }
    return join(" ", @$kvpairs);
}

sub tag_attributes     { return $_[0]->{_tag_attributes}  }
sub set_tag_attributes { $_[0]->{_tag_attributes} = $_[1] }
sub context     { return $_[0]->{_context}  }
sub set_context { $_[0]->{_context} = $_[1] }
sub render_state     { return $_[0]->{_render_state}  }
sub set_render_state { $_[0]->{_render_state} = $_[1] }
sub node_id     { return $_[0]->{_node_id}  }
sub set_node_id { $_[0]->{_node_id} = $_[1] }
sub parent     { return $_[0]->{_parent}  }
sub set_parent {
    $_[0]->{_parent} = $_[1];
    weaken $_[0]->{_parent};
}
sub parent_binding_name     { return $_[0]->{_parent_binding_name}  }
sub set_parent_binding_name { $_[0]->{_parent_binding_name} = $_[1] }

1;