package Prospero::Component::System::TextField;

use strict;
use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

use Prospero::PageResource;


sub required_page_resources {
    my ( $self ) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/IF/TextField.js"),
    ];
}

sub reset_values {
    my ($self) = @_;
    delete $self->{_name};
    delete $self->{_size};
    delete $self->{_max_length};
    delete $self->{_value};
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->SUPER::take_values_from_request( $request, $context );
    $self->set_value( $request->form_value_for_key( $self->name() ) );
    print STDERR "Value of input field ".$self->name()." is ".$self->value();
}

sub name {
    my ( $self ) = @_;
    return $self->{_name} || $self->node_id();
}
sub set_name { $_[0]->{_name} = $_[1] }

sub size     { return $_[0]->{_size}  }
sub set_size { $_[0]->{_size} = $_[1] }
sub max_length     { return $_[0]->{_max_length}  }
sub set_max_length { $_[0]->{_max_length} = $_[1] }
sub value     { return $_[0]->{_value}  }
sub set_value { $_[0]->{_value} = $_[1] }

1;