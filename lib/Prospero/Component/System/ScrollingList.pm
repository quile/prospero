package Prospero::Component::System::ScrollingList;

use strict;
use base qw(
    Prospero::Component::System::PopUpMenu
);

use Prospero::PageResource;
use Prospero::Utility qw( array_from_object );

sub required_page_resources {
    my ( $self ) = @_;
    return [
        Prospero::PageResource->javascript( "/if-static/javascript/IF/ScrollingList.js" ),
    ];
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->SUPER::take_values_from_request( $request, $context );

    if ( $self->is_multiple() ) {
        $self->set_selection( $request->form_values_for_key( $self->name() ) );
    } else {
        $self->set_selection( $request->form_value_for_key( $self->name() ) );
    }
}

sub item_is_selected {
    my ( $self, $item ) = @_;

    my $value;

    if ( UNIVERSAL::can( $item, "value_for_key" ) ) {
        $value = $item->value_for_key( $self->value() );
    } elsif ( ref( $item ) eq "HASH" && exists $item->{$self->value()} ) {
        $value = $item->{ $self->value() };
    } else {
        $value = $item;
    }

    return 0 if $value eq "";

    my $selection = array_from_object( $self->selection() );

    foreach my $selected_value ( @$selection ) {
        unless (ref $selected_value) {
            return 1 if ( $selected_value eq $value );
            if ( $selected_value =~ /^[0-9\.]+$/ &&
                 $value =~ /^[0-9\.]+$/ &&
                 $selected_value == $value ) {
                return 1;
            }
            next;
        }
        if ( UNIVERSAL::can( $selected_value, "value_for_key" ) ) {
            return 1 if $selected_value->value_for_key( $self->value() ) eq $value;
        } else {
            return 1 if $selected_value->{ $self->value() } eq $value;
        }
    }
    return 0;
}

sub size     { return $_[0]->{_size}  }
sub set_size { $_[0]->{_size} = $_[1] }
sub is_multiple     { return $_[0]->{_is_multiple}  }
sub set_is_multiple { $_[0]->{_is_multiple} = $_[1] }

1;
