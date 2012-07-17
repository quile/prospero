package Prospero::Component::System::Form;

use strict;
use base qw(
    Prospero::Component::System::Hyperlink
);

use Prospero::BindingDictionary;

sub required_page_resources {
    my ($self) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/jquery/jquery-1.2.6.js"),
        Prospero::PageResource->javascript("/if-static/javascript/jquery/plugins/jquery.if.js"),
        Prospero::PageResource->javascript("/if-static/javascript/IF/Component.js"),
        Prospero::PageResource->javascript("/if-static/javascript/IF/FormComponent.js"),
        Prospero::PageResource->javascript("/if-static/javascript/IF/Form.js"),
        Prospero::PageResource->javascript("/if-static/javascript/IF/Validator.js"),
    ];
}

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->set_method("POST");
}

sub id     { return $_[0]->{_id} || $_[0]->node_id() }
sub set_id { $_[0]->{_id} = $_[1] }
sub method     { return $_[0]->{_method}  }
sub set_method { $_[0]->{_method} = $_[1] }
sub enc_type     { return $_[0]->{_enc_type}  }
sub set_enc_type { $_[0]->{_enc_type} = $_[1] }
sub name     { return $_[0]->{_name}  }
sub set_name { $_[0]->{_name} = $_[1] }
sub can_only_be_submitted_once     { return $_[0]->{_can_only_be_submitted_once}  }
sub set_can_only_be_submitted_once { $_[0]->{_can_only_be_submitted_once} = $_[1] }

sub form_name     { return $_[0]->name() || $_[0]->node_id() }

# sub appendToResponse {
#     my ($self, $response, $context) = @_;
#
#     # every form needs to emit the context number so the responding
#     # process knows if it has been called in order.
#     $self->{queryDictionaryAdditions}->addObject(
#                 { NAME => "context-number",
#                   VALUE => $self->context()->session()->contextNumber(),
#                 });
#     return $self->SUPER::appendToResponse($response, $context);
# }

sub set_is_multipart {
    my ( $self, $value ) = @_;
    if ( $value ) {
        $self->set_enc_type("multipart/form-data");
    } else {
        $self->set_enc_type();
    }
}

sub bindings {
    my ( $self ) = @_;
    return Prospero::BindingDictionary->new({
        content => {
            type => "CONTENT",
        },
    });
}

# sub validationErrorMessagesArray {
#     my ($self) = @_;
#     my $h = $self->validationErrorMessages();
#     return [map {'key' => $_, 'value' => $h->{$_} }, keys %$h];
# }
#
# sub validationErrorMessages {
#     my ($self) = @_;
#     return $self->{validationErrorMessages} || {};
# }
#
# sub setValidationErrorMessages {
#     my ($self, $value) = @_;
#     $self->{validationErrorMessages} = $value;
# }

1;
