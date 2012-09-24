package Prospero::Plugin::Javascript;

use strict;
use warnings;

use base qw( Prospero::Plugin );

use Data::Dumper;

__PACKAGE__->register_plugin(
    callbacks => {
        will_render => sub {
            my ( $component, $response, $context ) = @_;
            # build the tree of components here
        },
        did_render => sub {
            my ( $component, $response, $context ) = @_;
            # insert the JS that builds the client-side page structure
            # if did_render is called on the root component
        },
    },
);

1;