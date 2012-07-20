package Unit::Component::FormTest;

use strict;
use warnings;
use base qw( Prospero::Plugin::TT2::Component);

use Prospero::BindingDictionary;
use Prospero::PageResource;

use Prospero::Component::System::Components;

sub init {
    my ( $self ) = @_;
    $self->SUPER::init();
    $self->set_stuff({
        text_field => "Me text",
        hidden_field => "You hidden",
        password => "xyzzy",
        text => "Ethel the Aardvark Goes Quantity Surveying",
        popup => "pink",
        radio_button_group => "yellow",
        scrolling_list => [ "white", "davis" ],
        check_box_group => [ "higgins", "thorburn" ],
    });
}

sub stuff     { return $_[0]->{_stuff}  }
sub set_stuff { $_[0]->{_stuff} = $_[1] }

sub append_to_response {
    my ( $self, $response, $context ) = @_;

    $self->SUPER::append_to_response( $response, $context );
}

sub bindings {
    return Prospero::BindingDictionary->new({
        form => {
            type => "Prospero::Component::System::Form",
            action => sub { '/foo/bar/baz' },
        },
        hidden_field => {
            type => "Prospero::Component::System::HiddenField",
            value => q(stuff.hidden_field),
        },
        text_field => {
            type => "Prospero::Component::System::TextField",
            value => q(stuff.text_field),
        },
        password => {
            type => "Prospero::Component::System::Password",
            value => q(stuff.text_field),
        },
        text => {
            type => "Prospero::Component::System::Text",
            value => q(stuff.text),
        },
        popup_menu => {
            type => "Prospero::Component::System::PopUpMenu",
            selection => q(stuff.popup),
            values => sub {[
                qw( blue pink black )
            ]},
            labels => sub {{
                blue => "Blue!",
                pink => "Pink!",
                black => "Black!",
            }},
            allows_no_selection => sub { 1 },
            any_string => sub { "Pick a colour" },
        },
        scrolling_list => {
            type => "Prospero::Component::System::ScrollingList",
            selection => q(stuff.scrolling_list),
            values => sub {[
                qw( davis mountjoy o_sullivan white hendry )
            ]},
            labels => sub {{
                davis => "Steve Davis",
                mountjoy => "Doug Mountjoy",
                o_sullivan => "Ronnie O'Sullivan",
                white => "Jimmy White",
                hendry => "Stephen Hendry",
            }},
        },
        radio_buttons => {
            type => "Prospero::Component::System::RadioButtonGroup",
            selection => q(stuff.radio_button_group),
            values => sub {[
                qw( yellow green brown )
            ]},
            labels => sub {{
                yellow => "Yellow!",
                green => "Green!",
                brown => "Brown!",
            }},
        },
        check_box_group => {
            type => "Prospero::Component::System::CheckBoxGroup",
            selection => q(stuff.check_box_group),
            values => sub {[
                qw( higgins taylor thorburn )
            ]},
            labels => sub {{
                higgins => "Alex 'Hurricane' Higgins",
                taylor => "Dennis Taylor",
                thorburn => "Cliff Thorburn",
            }},
        },
        submit_button => {
            type => "Prospero::Component::System::SubmitButton",
            value => sub { 'Click me!' },
        },
    });
}

1;