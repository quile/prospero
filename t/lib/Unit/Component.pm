package Unit::Component;

use strict;

use base qw( Test::Class );

use Test::More;
use Data::Dumper;

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

sub test_render : Tests {
    my ( $self ) = @_;

    my $c = Unit::Component::Hello->new();
    my $output = $c->render_in_context( $self->{_context} );
    #diag $output;
    ok( $output, "rendered content" );
    ok( $output =~ /Hi!/, "text matches" );
    ok( $output =~ /bar/, "foo rendered" );
    ok( $output =~ /baz/, "bar rendered" );
}

sub test_component_tree : Tests {
    my ( $self ) = @_;
    my $c = Unit::Component::Hello->new();
    my $output = $c->render_in_context( $self->{_context} );
    ok( $output =~ /This is the root/, "Root component rendered" );
    ok( $output =~ /This is SPARTA/, "One subcomponent rendered" );
    ok( $output =~ /SPARTACUS/, "Second subcomponent rendered"   );
}

sub test_push_bindings : Tests {
    my ( $self ) = @_;

    my $component = Unit::Component::Hello->new();
    my $output = $component->render_in_context( $self->{_context} );

    ok( $output =~ /goo from above/, "Subcomponent had value pushed in from above" );
}

sub test_pull_bindings : Tests {
    my ( $self ) = @_;

    my $context = Prospero::Context->new({
        environment => {
            TT2_CONFIG => {
                INCLUDE_PATH => "t/templates",
                DEBUG => 1,
            },
        },
        outgoing_request_frame => Prospero::RequestFrame->new(),
    });

    my $component = Unit::Component::Hello->new();
    my $output = $component->render_in_context( $context );

    $context->set_incoming_request_frame( $context->outgoing_request_frame() );
    $context->set_outgoing_request_frame();

    my $request = Prospero::Request::Offline->new( params => { "1_3" => [ "fruity fun!" ], } );
    $component->rewind_request_in_context( $request, $context );

    ok( $component->mango() eq "fruity fun!", "Pulled value from subcomponent" );
}

sub test_page_resources : Tests {
    my ( $self ) = @_;
    my $c = Unit::Component::Hello->new();
    my $output = $c->render_in_context( $self->{_context} );
    my $render_state = $c->render_state();
    diag Dumper( $render_state );

    ok( scalar @{ $render_state->page_resources() } == 3, "correct number of page resources" );
    ok( $output =~ m!src="/foo/bar/bananas.js!, "Tags appear for page resources" );
}

sub test_tag_attributes : Tests {
    my ( $self ) = @_;
    my $c = Unit::Component::Hello->new();
    my $output = $c->render_in_context( $self->{_context} );
    ok( $output =~ /Belch: ok/, "Tag attributes read by component correctly" );
}

1;