package Unit::Component::FormTest;

use strict;
use warnings;
use base qw( Prospero::Plugin::TT2::Component);

use Prospero::BindingDictionary;
use Prospero::PageResource;

use Prospero::Component::System::Components;

use Data::Dumper;

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
        date_editor => "1944-06-06",
        time_editor => "16:20:00",
    });
}

sub stuff     { return $_[0]->{_stuff}  }
sub set_stuff { $_[0]->{_stuff} = $_[1] }

sub submit {
    my ( $self, $context ) = @_;

    print STDERR "Submitted form info:";
    print STDERR Dumper( $self->stuff() );

    return undef;
}

sub bindings {
    return Prospero::BindingDictionary->new({
        form => {
            type => "Prospero::Component::System::Form",
            action => sub { '/foo/bar/submit' },
            method => sub { 'GET' },
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
            value => q(stuff.password),
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
        date_editor => {
            type => "Prospero::Component::System::DateEditor",
            date_string => q(stuff.date_editor),
            start_year => sub { "1939" },
            end_year => sub { "1945" },
        },
        time_editor => {
            type => "Prospero::Component::System::TimeEditor",
            time_string => q(stuff.time_editor),
            should_show_seconds => sub { 1 },
            is_twenty_four_hour => sub { 1 },
        },
        submit_button => {
            type => "Prospero::Component::System::SubmitButton",
            value => sub { 'Click me!' },
        },
    });
}

1;