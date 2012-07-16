package Prospero::Plugin::TT2::Component;

use strict;
use warnings;

use base qw( Prospero::Component );

use Prospero::Plugin::TT2::Grammar;

use Template;
use Carp qw( croak );
use Data::Dumper;

sub _engine {
    my ( $self, $context ) = @_;
    $context->environment()->{_TT2} ||= Template->new({
        %{$context->environment()->{TT2_CONFIG}},
        GRAMMAR => Prospero::Plugin::TT2::Grammar->new(),
    });
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    unless ( $context->incoming_request_frame()->did_render_component( $self ) ) {
        print STDERR "Did not render component $self with id ".$self->node_id()." in frame\n";
        return;
    }
    print STDERR "Component ".ref( $self )." - ".$self->node_id()." taking values\n";

    $self->set_context( $context );
    my $engine = $self->_engine( $context );
    my $template_path = $self->template_path();

    my $output;
    unless ( $engine->process( $template_path, {
            self => $self,
            prospero__ => {
                __action => "pull",
                __request => $request,
            }
        }, \$output ) ) {
        die $engine->error;
    }

    $self->set_context( undef );
}

sub will_render {
    my ( $self, $response, $context ) = @_;
    $self->SUPER::will_render( $response, $context );
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
    unless ( $engine->process( $template_path, {
            self => $self,
            prospero__ => {
                __action => "push",
                __response => $response,
            },
        }, \$output ) ) {
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
    return "$name.tt2";
}

# rename this
sub bind {
    my ( $self, $name, $prospero, $tag_attributes ) = @_;

    croak( "No meta-information passed in" ) unless $prospero;

    $DB::single = 1;
    # get binding with name
    my $binding = $self->binding_with_name( $name ) or die "No such binding: $name";

    if ( $binding->type() eq "CONTENT" ) {
        return ( Prospero::Component::CONTENT_TAG(), undef );
    }

    # determine component type and instantiate
    my $component = $self->component_for_binding( $binding ) or die "Can't instantiate component for binding $name";

    $component->set_tag_attributes( $tag_attributes || {} );

    $component->set_parent( $self );
    # bind values into it
    $self->push_values_to_component( $component, $binding );

    # render or unwind
    if ( $prospero->{__action} eq "pull" ) {
        $component->rewind_request_in_context( $prospero->{__request}, $self->context() );
        $self->pull_values_from_component( $component, $binding );
        return ("", "");
    } elsif ( $prospero->{__action} eq "push" ) {
        my $content = $component->render_in_context( $self->context() );
        return split( quotemeta(Prospero::Component::CONTENT_TAG()), $content );
    }
}

#-------------------------------------------------------
# Monkey patch the Template::Directive class
# to have the directive we need to achieve awesomeness
#-------------------------------------------------------

package Template::Directive;

use strict;
use warnings;

sub bind {
    my ( $class, $nameargs, $block ) = @_;

    my ( $names, $args ) = @$nameargs;
    my $hash = shift @$args;
    my $v = @$hash ? '{ ' . join( ', ', @$hash ) . ' }' : '';
    my $name = shift @$names;

    if ( $block ) {
        $block = pad( $block, 2 ) if $Template::Directive::PRETTY;

        return <<EOP
do {
my (\$start, \$finish) = \$stash->get("self")->bind( $name, \$stash->get("prospero__"), $v );

\$output .= \$start;
$block
\$output .= \$finish;
};
EOP
;
    } else {
        return <<EOP
do {
my (\$start, \$finish) = \$stash->get('self')->bind( $name, \$stash->get("prospero__"), $v );
#if ( \$finish ) { die "Component $name expects to wrap content" }
\$output .= \$start;
};
EOP
;
    }
}

1;