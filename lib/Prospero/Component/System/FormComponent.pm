package Prospero::Component::System::FormComponent;

use strict;
use warnings;

use base qw( Prospero::Component );

sub id     { return $_[0]->{_id} || $_[0]->node_id() }
sub set_id { $_[0]->{_id} = $_[1] }
sub name {
    my ( $self ) = @_;
    return $self->{_name} || $self->node_id();
}
sub set_name { $_[0]->{_name} = $_[1] }

sub is_required     {
    my ( $self ) = @_;
    return $self->{_is_required}
        || $self->tag_attribute_for_key("isRequired")
        || $self->tag_attribute_for_key("is_required");
}
sub set_is_required { $_[0]->{_is_required} = $_[1] }

sub is_required_message     {
    my ( $self ) = @_;
    return $self->{_is_required_message}
        || $self->tag_attribute_for_key("isRequiredMessage")
        || $self->tag_attribute_for_key("is_required_message");
}
sub set_is_required_message { $_[0]->{_is_required_message} = $_[1] }

sub validation_failure_message     {
    my ( $self ) = @_;
    return $self->{_validation_failure_message}
        || $self->tag_attribute_for_key("validationFailureMessage")
        || $self->tag_attribute_for_key("validation_failure_message");
}
sub set_validation_failure_message { $_[0]->{_validation_failure_message} = $_[1]  }

sub validator     { return $_[0]->{_validator}  }
sub set_validator { $_[0]->{_validator} = $_[1] }

# sub hasValidValues {
#     my ( $self ) = @_;
#     if ( $self->is_required() && !$self->has_value_for_validation() ) {
#         return 0;
#     }
#     return 1;
# }
#
# sub hasValueForValidation {
#     my ( $self ) = @_;
#     $self->unimplemented();
# }

1;