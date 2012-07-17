package Prospero::Component::System::SubmitButton;

use strict;
use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

sub required_page_resources {
    my ($self) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/IF/SubmitButton.js"),
    ];
}

sub init {
    my ( $self ) = @_;
    $self->SUPER::init();
    $self->set_should_validate_form(1);
}

sub name {
    my ( $self ) = @_;
    return $self->{_name} || $self->node_id();

    # if ($self->directAction()) {
    #     IF::Log::debug("We have a direct action, so returning _ACTION:".$self->targetComponent()."/".$self->directAction());
    #     return "_ACTION:".$self->targetComponent()."/".$self->directAction();
    # }
}

# sub direct_action     { return $_[0]->{_direct_action}  }
# sub set_direct_action { $_[0]->{_direct_action} = $_[1] }
# sub target_component     { return $_[0]->{_target_component}  }
# sub set_target_component { $_[0]->{_target_component} = $_[1] }

sub _alternateValue {
    my ($self) = @_;
    return $self->alternate_value()
        || $self->tag_attribute_for_key( "alternateValue" )
        || "...";  # TODO: hmm - at least localize
}

sub value     { return $_[0]->{_value}  }
sub set_value { $_[0]->{_value} = $_[1] }
sub alternate_value     { return $_[0]->{_alternate_value}  }
sub set_alternate_value { $_[0]->{_alternate_value} = $_[1] }
sub can_only_be_clicked_once     { return $_[0]->{_can_only_be_clicked_once} || $_[0]->tag_attribute_for_key("canOnlyBeClickedOnce") }
sub set_can_only_be_clicked_once { $_[0]->{_can_only_be_clicked_once} = $_[1] }
sub should_validate_form     { return $_[0]->{_should_validate_form} || $_[0]->tag_attribute_for_key("shouldValidateForm") }
sub set_should_validate_form { $_[0]->{_should_validate_form} = $_[1] }

1;