package Prospero::Component::TT2;

use strict;
use warnings;

use base qw( Prospero::Component );

use Prospero::Component::TT2::Grammar;

use Template;

sub CONTENT_TAG { quotemeta( "<__CONTENT__>" ) }

sub _engine {
    my ( $self, $context ) = @_;
    $context->environment()->{_TT2} ||= Template->new({
        %{$context->environment()->{TT2_CONFIG}},
        GRAMMAR => Prospero::Component::TT2::Grammar->new(),
    });
}

sub render_in_context {
    my ( $self, $context ) = @_;

    my $engine = $self->_engine( $context );
    my $template_path = $self->template_path();
    my $output;
    unless ( $engine->process( $template_path, { self => $self }, \$output ) ) {
        die $engine->error;
    }
    return $output;
}

# Override if you want
sub template_path {
    my ( $self ) = @_;
    my $name = ref( $self );
    $name =~ s/::/\//g;
    return "$name.html";
}

sub bind {
    my ( $self, $name ) = @_;
    # get binding with name

    my $binding = $self->binding_with_name( $name ) or die "No such binding: $name";

    # determine component type and instantiate
    my $component = $self->component_for_binding( $binding ) or die "Can't instantiate component for binding $name";

    # bind values into it
    $self->push_values_to_component( $component );

    # render or unwind
    my $content = $component->render_in_context( $context );

    # pull values out
    $self->pull_values_from_component( $component );

    # return content

    return ( "BIND( $name )\n", "END( $name )\n" );
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