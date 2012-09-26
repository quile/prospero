package Prospero::Plugin::Javascript;

use strict;
use warnings;

use base qw( Prospero::Plugin );

use Data::Dumper;

__PACKAGE__->register_plugin(
    callbacks => {
        component_will_render => sub {
            my ( $component, $response, $context ) = @_;
            # build the tree of components here
        },
        component_did_render => sub {
            my ( $component, $response, $context ) = @_;
            # insert the JS that builds the client-side page structure
        },
        page_did_render => sub {
            my ( $page, $response, $context ) = @_;

        },
    },
);

1;