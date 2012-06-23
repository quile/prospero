package Prospero::Component::TT2;

use strict;
use warnings;

use base qw( Prospero::Component );

use Prospero::Component::TT2::Grammar;

use Template;

sub _engine {
    my ( $self, $context ) = @_;
    $context->environment()->{_TT2} ||= Template->new({
        %{$context->environment()->{TT2_CONFIG}},
        GRAMMAR => Prospero::Component::TT2::Grammar->new(),
    });
}

sub will_render {
    my ( $self, $context ) = @_;
    $self->SUPER::will_render( $context );
}

sub append_to_response {
    my ( $self, $response, $context ) = @_;

    # stuff the context away
    $self->set_context( $context );

    # TODO:kd - get engine from context?
    my $engine = $self->_engine( $context );

    # call this to get the template path - override
    # this to
    my $template_path = $self->template_path();

    my $output;
    unless ( $engine->process( $template_path, { self => $self }, \$output ) ) {
        die $engine->error;
    }

    # append to the response if there is one
    if ( $response ) {
        $response->append_content_string( $output );
    }

    $self->set_context( undef );

    # return the rendered output
    return $output;
}

sub did_render {
    my ( $self, $response, $context ) = @_;
    $self->SUPER::did_render( $response, $context );
}

# Override if you want
sub template_path {
    my ( $self ) = @_;
    my $name = ref( $self );
    $name =~ s/::/\//g;
    return "$name.html";
}

# rename this
sub bind {
    my ( $self, $name ) = @_;

    # get binding with name
    my $binding = $self->binding_with_name( $name ) or die "No such binding: $name";

    if ( $binding->type() eq "CONTENT" ) {
        return ( Prospero::Component::CONTENT_TAG(), undef );
    }

    # determine component type and instantiate
    my $component = $self->component_for_binding( $binding ) or die "Can't instantiate component for binding $name";

    # bind values into it
    #$self->push_values_to_component( $component );

    # render or unwind
    my $content = $component->render_in_context( $self->context() );

    # pull values out
    #$self->pull_values_from_component( $component );

    return split( quotemeta(Prospero::Component::CONTENT_TAG()), $content );
}

#-------------------------------------------------------
# Monkey patch the Template::Directive class
# to have the directive we need to achieve awesomeness
#-------------------------------------------------------

package Template::Directive;

use strict;
use warnings;

sub bind {
    my ( $class, $name, $block ) = @_;

    if ( $block ) {
        $block = pad( $block, 2 ) if $Template::Directive::PRETTY;

        return <<EOP
do {
my (\$start, \$finish) = \$stash->get("self")->bind( $name );

\$output .= \$start;
$block
\$output .= \$finish;
};
EOP
;
    } else {
        return <<EOP
do {
my (\$start, \$finish) = \$stash->get('self')->bind( $name );
#if ( \$finish ) { die "Component $name needs to wrap content" }
\$output .= \$start;
};
EOP
;
    }
}

1;