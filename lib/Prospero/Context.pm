package Prospero::Context;

use strict;
use warnings;

use base qw( Prospero::Object );

sub environment       { return $_[0]->{_environment}   }
sub set_environment   { $_[0]->{_environment} = $_[1]  }
sub render_state      {
    my ( $self ) = @_;
    return $_[0]->{_render_state} ||= Prospero::RenderState->new();
}
sub set_render_state  { $_[0]->{_render_state} = $_[1] }
sub outgoing_request_frame     { return $_[0]->{_outgoing_request_frame}  }
sub set_outgoing_request_frame { $_[0]->{_outgoing_request_frame} = $_[1] }
sub incoming_request_frame     { return $_[0]->{_incoming_request_frame}  }
sub set_incoming_request_frame { $_[0]->{_incoming_request_frame} = $_[1] }
sub frame_number     { return $_[0]->{_frame_number}  }
sub set_frame_number { $_[0]->{_frame_number} = $_[1] }
sub transaction_values     { return $_[0]->{_transaction_values} ||= {}  }
sub set_transaction_values { $_[0]->{_transaction_values} = $_[1] }

sub set_transaction_value_for_key {
    my ( $self, $value, $key ) = @_;
    $self->transaction_values()->{$key} = $value;
}

sub transaction_value_for_key {
    my ( $self, $key ) = @_;
    return $self->transaction_values()->{$key};
}

1;