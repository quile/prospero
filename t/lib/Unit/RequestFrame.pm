package Unit::RequestFrame;

use strict;

use base qw( Test::Class );

use Test::More;

use Prospero::Component;
use Prospero::Context;
use Prospero::RequestFrame;
use Prospero::Request::Offline;

use Unit::Component::Hello;

sub setup : Test( startup ) {
    my ( $self ) = @_;

    # load the config
    $self->{_context} = Prospero::Context->new({
        environment => {
            TT2_CONFIG => {
                INCLUDE_PATH => "t/templates",
                DEBUG => 1,
            },
        },
        outgoing_request_frame => Prospero::RequestFrame->new(),
    });
}

sub test_request_frame : Tests {
    my ( $self ) = @_;
    my $c = Unit::Component::Hello->new();
    my $output = $c->render_in_context( $self->{_context} );

    my $request_frame = $self->{_context}->outgoing_request_frame();

    ok( $request_frame, "Retrieved request frame" );
    ok( $request_frame->did_render_component( $c ), "Did render root component" );

    my $faux = Unit::Component::Hello->new();
    $faux->set_node_id( 10 );
    ok( !$request_frame->did_render_component( $faux ), "Didn't render different component" );
}

1;