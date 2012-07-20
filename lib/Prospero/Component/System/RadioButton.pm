package Prospero::Component::System::RadioButton;

use strict;

use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->SUPER::take_values_from_request( $request, $context );

    my $value = $request->form_value_for_key( $self->name() );
    if ( $self->value() eq $value ) {
        $self->set_is_checked( 1 );
    }
}

sub name     { return $_[0]->{_name} || $_[0]->node_id() }
sub set_name { $_[0]->{_name} = $_[1] }
sub value     { return $_[0]->{_value}  }
sub set_value { $_[0]->{_value} = $_[1] }
sub is_negated     { return $_[0]->{_is_negated}  }
sub set_is_negated { $_[0]->{_is_negated} = $_[1] }

sub is_checked {
    my $self = shift;
    return (!$self->{_is_checked}) if $self->is_negated();
    return $self->{_is_checked};
}

sub set_is_checked {
    my $self = shift;
    $self->{_is_checked} = shift;
}

1;
