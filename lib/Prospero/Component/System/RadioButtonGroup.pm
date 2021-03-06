package Prospero::Component::System::RadioButtonGroup;

use strict;
use base qw(
    Prospero::Component::System::PopUpMenu
);

sub javascript_class { "prospero.RadioButtonGroup" }

sub init {
    my ( $self ) = @_;
    $self->SUPER::init(@_);
    $self->set_is_vertical( 1 );
}

sub should_render_in_table     { return $_[0]->{_should_render_in_table}  }
sub set_should_render_in_table { $_[0]->{_should_render_in_table} = $_[1] }
sub is_vertical     { return $_[0]->{_is_vertical}  }
sub set_is_vertical { $_[0]->{_is_vertical} = $_[1] }

sub bindings {
    my ( $self ) = @_;
    return $self->SUPER::bindings()->push_frame({
        button => {
            type => "Prospero::Component::System::RadioButton",
            name => q(name),
            value => q(self.value_for_item(self.stash_value_for_key('item'))),
            is_checked => q(self.item_is_selected(self.stash_value_for_key('item'))),
        },
    });
}

1;
