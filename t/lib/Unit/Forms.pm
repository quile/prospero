package Unit::Forms;

use strict;

use base qw( Test::Class );

use Test::More;
use Data::Dumper;
use Storable qw( dclone );

use Prospero::Component;
use Prospero::Context;
use Prospero::RequestFrame;
use Prospero::Request::Offline;

use Prospero::Component::System::Components;

use Unit::Component::FormTest;

sub setup : Test( startup ) {
    my ( $self ) = @_;

    # load the config
    $self->{_context} = Prospero::Context->new({
        environment => {
            TT2_CONFIG => {
                INCLUDE_PATH => [ "share/templates/en", "t/templates", ],
                DEBUG => 1,
            },
        },
        outgoing_request_frame => Prospero::RequestFrame->new(),
    });

    $self->{_component} = Unit::Component::FormTest->new();
    my $output = $self->{_component}->render_in_context( $self->{_context} );
    ok ( $output, "rendered content" );
    diag $output;

    $self->{_outgoing_request_frame} = $self->{_context}->outgoing_request_frame();
}

sub test_rewind : Tests {
    my ( $self ) = @_;

    my $request = Prospero::Request::Offline->new(
        params => {
            "1_2" => "Your mother was a hamster",
            "1_3" => "and your father smelt of elderberries.",
            "1_4" => "I am Arthur, King of the Britons.",
            "1_5" => "Three shall be the number of the counting.",
            "1_6" => "black",
            "1_7" => [ "mountjoy", "hendry" ],
            "1_8" => "brown",
            "1_9" => [ "taylor", "thorburn" ],
        },
    );
    $self->{_context}->set_incoming_request_frame( $self->{_outgoing_request_frame} );
    $self->{_context}->set_outgoing_request_frame();

    $self->{_component}->rewind_request_in_context( $request, $self->{_context} );

    diag Dumper $self->{_component}->stuff();
    is_deeply( $self->{_component}->stuff(), {
            'scrolling_list' => [
                'mountjoy',
                'hendry'
            ],
            'hidden_field' => 'I am Arthur, King of the Britons.',
            'radio_button_group' => 'brown',
            'password' => 'and your father smelt of elderberries.',
            'text' => 'Three shall be the number of the counting.',
            'check_box_group' => [
                'taylor',
                'thorburn'
            ],
            'popup' => 'black',
            'text_field' => 'Your mother was a hamster'
        },
        "Pulled values from request into structured object",
    )
}

1;