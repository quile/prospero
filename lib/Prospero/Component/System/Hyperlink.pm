package Prospero::Component::System::Hyperlink;

use strict;
use base qw(
    Prospero::Component::System::URL
);
use JSON;


# This has been unrolled to speed it up; do not be tempted to do this
# anywhere else!

sub append_to_response {
    my ( $self, $response, $context ) = @_;

    if ( ref( $self ) eq "Prospero::Component::System::Hyperlink" ) {

        $context->render_state()->add_page_resources( $self->required_page_resources() );

        # asString is compiled response of IF::Component::URL
        my $html = [q#<a href="#, $self->as_string(), q#"#];

        if ($self->title()) {
            push @$html, ' title="', $self->title(), '"';
        }

        #   <BINDING:TAG_ATTRIBUTES>
        push @$html, ' ', $self->tag_attribute_string(),' >';
        #    <BINDING:CONTENT>
        #</A>
        push @$html, $self->CONTENT_TAG(),'</a>';

        $response->set_content( join( '', @$html ) );
        return;
    } else {
        $self->SUPER::append_to_response( $response, $context );
    }
}

sub url {
    my ($self) = @_;
    return $self->SUPER::url() || $self->tag_attribute_for_key("url");
}

sub title {
    my ( $self ) = @_;
    return $self->{title} ||= $self->tag_attribute_for_key("title");
}

sub set_title {
    my ( $self, $value ) = @_;
    $self->{title} = $value;
}

1;