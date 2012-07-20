package Prospero::Component::System::CheckBox;

use strict;

use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->SUPER::take_values_from_request( $request, $context );
    $self->set_value( $request->param( $self->name() ) );
}

1;
